defmodule Magma.Artefact.PromptResult do
  use Magma.Document, fields: [:prompt, :generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Concept, Generation, Utils}

  import Magma.Utils, only: [init_field: 2]

  def build_name(%Concept{} = concept, artefact) do
    "Generated #{artefact.name(concept)}"
  end

  @impl true
  def build_path(
        %__MODULE__{prompt: %Artefact.Prompt{artefact: artefact, concept: concept}} = result
      ) do
    {:ok,
     [
       concept |> artefact.relative_prompt_path() |> Path.dirname(),
       "__prompt_results__",
       "#{build_name(concept, artefact)} (#{result.created_at |> DateTime.to_naive() |> NaiveDateTime.to_iso8601()}).md"
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
    document =
      Document.init(document,
        generation: document.prompt.generation || Generation.default().new!()
      )

    with {:ok, content} <- execute_prompt(document) do
      Document.create_file(document, content, opts)
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
      {:ok, render(document, result)}
    end
  end

  defp render(document, result) do
    import Magma.Obsidian.View.Helper

    """
    ---
    magma_type: Artefact.PromptResult
    magma_prompt: "#{link_to(document.prompt)}"
    magma_generation_type: #{inspect(Magma.Generation.short_name(document.generation))}
    magma_generation_params: #{yaml_nested_map(document.generation)}
    created_at: #{document.created_at}
    tags: #{yaml_list(document.tags)}
    aliases: #{yaml_list(document.aliases)}
    ---
    #{button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
    #{delete_current_file_button()}

    # #{build_name(document.prompt.concept, document.prompt.artefact)}

    #{result}
    """
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = prompt_result) do
    {prompt_link, metadata} = Map.pop(prompt_result.custom_metadata, :magma_prompt)

    if prompt_link do
      prompt_link
      |> Utils.extract_link_text()
      |> Vault.document_path()
      |> case do
        nil ->
          {:error, "invalid magma_prompt link: #{prompt_link}"}

        document_path ->
          with {:ok, prompt} <- Artefact.Prompt.load(document_path),
               {:ok, generation, metadata} <- Generation.extract_from_metadata(metadata) do
            {:ok,
             %__MODULE__{
               prompt_result
               | prompt: prompt,
                 generation: generation,
                 custom_metadata: metadata
             }}
          end
      end
    else
      {:error, "magma_prompt missing"}
    end
  end
end
