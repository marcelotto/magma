defmodule Magma.Artefact.PromptResult do
  use Magma.Document, fields: [:prompt, :generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Generation}

  import Magma.Utils, only: [init_field: 2, set_file_read_only: 1]

  @impl true
  def title(%__MODULE__{prompt: %Artefact.Prompt{artefact: artefact, concept: concept}}) do
    "Generated #{artefact.name(concept)}"
  end

  def build_name(%__MODULE__{} = result) do
    "#{title(result)} (#{result.created_at |> DateTime.to_naive() |> NaiveDateTime.to_iso8601()})"
  end

  @impl true
  def build_path(
        %__MODULE__{prompt: %Artefact.Prompt{artefact: artefact, concept: concept}} = result
      ) do
    {:ok,
     [
       concept |> artefact.relative_prompt_path() |> Path.dirname(),
       "__prompt_results__",
       "#{build_name(result)}.md"
     ]
     |> Vault.artefact_generation_path()}
  end

  def new(prompt, attrs \\ []) do
    struct(__MODULE__, [{:prompt, prompt} | attrs])
    |> init_field(created_at: DateTime.utc_now())
    |> Document.init_path()
  end

  def new!(prompt, attrs \\ []) do
    case new(prompt, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(prompt, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, []) do
    with {:ok, document} <-
           document
           |> Document.init(generation: document.prompt.generation || Generation.default().new!())
           |> execute_prompt(),
         {:ok, document} <- Document.save(document, opts),
         :ok <- set_file_read_only(document.path) do
      {:ok, document}
    end
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Artefact.PromptResult.create/3 is available only with new/2 arguments"
      )

  def create(prompt, attrs, opts) do
    with {:ok, document} <- new(prompt, attrs) do
      create(document, opts)
    end
  end

  defp execute_prompt(%__MODULE__{} = document) do
    with {:ok, system_prompt, prompt} <- Artefact.Prompt.messages(document.prompt),
         {:ok, result} <- Generation.execute(document.generation, prompt, system_prompt) do
      {:ok, %__MODULE__{document | content: render(document, result)}}
    end
  end

  defp render(document, result) do
    import Magma.Obsidian.View.Helper

    """
    #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
    #{delete_current_file_button()}

    # #{title(document)}

    #{result}
    """
  end

  @impl true
  def render_front_matter(%__MODULE__{} = document) do
    import Magma.Obsidian.View.Helper

    """
    magma_prompt: "#{link_to(document.prompt)}"
    magma_generation_type: #{inspect(Magma.Generation.short_name(document.generation))}
    magma_generation_params: #{yaml_nested_map(document.generation)}
    """
    |> String.trim_trailing()
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = prompt_result) do
    {prompt_link, metadata} = Map.pop(prompt_result.custom_metadata, :magma_prompt)

    if prompt_link do
      with {:ok, prompt} <- Artefact.Prompt.load_linked(prompt_link),
           {:ok, generation, metadata} <- Generation.extract_from_metadata(metadata) do
        {:ok,
         %__MODULE__{
           prompt_result
           | prompt: prompt,
             generation: generation,
             custom_metadata: metadata
         }}
      end
    else
      {:error, "magma_prompt missing"}
    end
  end
end
