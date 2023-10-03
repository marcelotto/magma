defmodule Magma.PromptResult do
  use Magma.Document, fields: [:prompt, :generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Generation, Prompt}
  alias Magma.Document.Loader

  import Magma.Obsidian.View.Helper
  import Magma.Utils, only: [init_field: 2, set_file_read_only: 1]

  require Logger

  @impl true
  def title(%__MODULE__{prompt: %Prompt{} = prompt}) do
    "Prompt result of '#{prompt.name}'"
  end

  @impl true
  def title(%__MODULE__{prompt: %Artefact.Prompt{artefact: artefact, concept: concept}}) do
    "Generated #{artefact.name(concept)}"
  end

  def build_name(%__MODULE__{prompt: %Prompt{} = prompt} = result) do
    "#{prompt.name} (Prompt result #{result.created_at |> DateTime.to_naive() |> NaiveDateTime.to_iso8601()})"
  end

  def build_name(%__MODULE__{} = result) do
    "#{title(result)} (#{result.created_at |> DateTime.to_naive() |> NaiveDateTime.to_iso8601()})"
  end

  @impl true
  def build_path(%__MODULE__{prompt: %Prompt{}} = result) do
    {:ok,
     [Prompt.path_prefix(), "__prompt_results__", "#{build_name(result)}.md"]
     |> Vault.path()}
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

  @impl true
  def from(%__MODULE__{} = result), do: result
  def from(%Artefact.Version{} = version), do: version.draft

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
           |> execute_prompt(opts),
         {:ok, document} <- Document.create(document, opts) do
      make_read_only(document)
      {:ok, document}
    end
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.PromptResult.create/3 is available only with an initialized document"
      )

  def create(prompt, attrs, opts) do
    with {:ok, document} <- new(prompt, attrs) do
      create(document, opts)
    end
  end

  defp execute_prompt(%__MODULE__{} = document, opts) do
    with {:ok, result} <- Generation.execute(document.generation, document.prompt, opts) do
      {:ok, %__MODULE__{document | content: render(document, post_process_result(result, opts))}}
    end
  end

  defp post_process_result(result, opts) do
    result
    |> String.trim_leading()
    |> trim_header(Keyword.get(opts, :trim_header, true))
    |> String.trim_trailing()
  end

  defp trim_header("#" <> result, true) do
    case String.split(result, "\n", parts: 2) do
      [_, rest] -> String.trim_leading(rest)
      # It seems we're only getting a single header as a result, so we at least indent it.
      [only_header_result] -> "##" <> only_header_result
    end
  end

  defp trim_header(result, _), do: result

  defp render(prompt_result, execution_result) do
    """
    #{controls(prompt_result)}

    # #{title(prompt_result)}

    #{execution_result}
    """
  end

  def controls(%__MODULE__{prompt: %Prompt{}}) do
    delete_current_file_button()
  end

  def controls(%__MODULE__{prompt: %Artefact.Prompt{}} = prompt_result) do
    """
    #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
    #{delete_current_file_button()}

    Final version: #{link_to_version(prompt_result)}
    """
    |> String.trim_trailing()
  end

  @impl true
  def render_front_matter(%__MODULE__{} = document) do
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
      with {:ok, prompt} <- Loader.load_linked([Prompt, Artefact.Prompt], prompt_link),
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

  defp make_read_only(%__MODULE__{generation: %Generation.Manual{}} = result), do: result

  defp make_read_only(result) do
    case set_file_read_only(result.path) do
      :ok ->
        result

      {:error, error} ->
        Logger.warning("Failed to make #{result.path} read-only: #{inspect(error)}")
        result
    end
  end
end
