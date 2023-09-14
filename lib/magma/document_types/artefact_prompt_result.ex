defmodule Magma.Artefact.PromptResult do
  use Magma.Document, fields: [:prompt, :generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Generation, Utils}

  import Magma.Utils, only: [init_field: 2]

  def build_name(%artefact_type{concept: concept}) do
    "Generated #{artefact_type.build_name(concept)}"
  end

  @impl true
  def build_path(
        %__MODULE__{prompt: %Artefact.Prompt{artefact: %artefact_type{} = artefact}} = result
      ) do
    {:ok,
     [
       artefact |> artefact_type.build_prompt_path() |> Path.dirname(),
       "__prompt_results__",
       "#{build_name(artefact)} (#{result.created_at |> DateTime.to_naive() |> NaiveDateTime.to_iso8601()}).md"
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
           |> Document.init()
           |> execute_prompt(),
         {:ok, document} <- Document.create_file_from_template(document, opts) do
      Document.Loader.load(document)
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
    %generation_type{} = generation = document.generation || Generation.default().new!()

    with {:ok, system_prompt, prompt} <- Artefact.Prompt.messages(document.prompt),
         {:ok, result} <- generation_type.execute(generation, prompt, system_prompt) do
      {:ok,
       %__MODULE__{
         document
         | generation: generation,
           content: """
           #{Magma.Obsidian.View.Helper.button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
           #{Magma.Obsidian.View.Helper.delete_current_file_button()}

           # #{build_name(document.prompt.artefact)}

           #{result}
           """
       }}
    end
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = prompt_result) do
    {prompt_link, custom_metadata} = Map.pop(prompt_result.custom_metadata, :magma_prompt)
    {generation_type, custom_metadata} = Map.pop(custom_metadata, :magma_generation_type)
    {generation_params, custom_metadata} = Map.pop(custom_metadata, :magma_generation_params)

    cond do
      !prompt_link ->
        {:error, "magma_concept missing"}

      !generation_type || !generation_params ->
        {:error, "magma_generation metadata missing"}

      generation_module = Generation.type(generation_type) ->
        prompt_link
        |> Utils.extract_link_text()
        |> Vault.document_path()
        |> case do
          nil ->
            {:error, "invalid magma_prompt link: #{prompt_link}"}

          document_path ->
            with {:ok, prompt} <- Artefact.Prompt.load(document_path),
                 {:ok, generation} <- generation_module.new(generation_params) do
              {:ok,
               %__MODULE__{
                 prompt_result
                 | prompt: prompt,
                   generation: generation,
                   custom_metadata: custom_metadata
               }}
            end
        end

      true ->
        {:error, "invalid magma_generation_type type: #{generation_type}"}
    end
  end
end
