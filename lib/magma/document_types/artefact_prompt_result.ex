defmodule Magma.Artefact.PromptResult do
  use Magma.Document, fields: [:prompt, :generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Generation, Utils}

  @impl true
  def dependency, do: :prompt

  def build_name(%artefact_type{concept: concept}) do
    "Generated #{artefact_type.build_name(concept)}"
  end

  @impl true
  def build_path(
        %__MODULE__{prompt: %Artefact.Prompt{artefact: %artefact_type{} = artefact}} = result
      ) do
    {:ok,
     [
       artefact |> artefact_type.prompt_path() |> Path.dirname(),
       "prompt_results",
       "#{build_name(artefact)} (#{result.created_at |> DateTime.to_naive() |> NaiveDateTime.to_iso8601()}).md"
     ]
     |> Path.join()
     |> Vault.artefact_path()}
  end

  @impl true
  def new_document(%__MODULE__{} = document) do
    {:ok, init_created_at(document)}
  end

  def new_document(document), do: super(document)

  defp init_created_at(%__MODULE__{created_at: nil} = document) do
    %{document | created_at: DateTime.utc_now()}
  end

  defp init_created_at(%__MODULE__{} = document), do: document

  @impl true
  def create_document(%__MODULE__{} = document) do
    %generation_type{} = generation = document.generation || Generation.default().new!()

    with {:ok, system_prompt, prompt} <- Artefact.Prompt.messages(document.prompt),
         {:ok, result} <- generation_type.execute(generation, prompt, system_prompt) do
      {:ok,
       %__MODULE__{
         document
         | generation: generation,
           content: """
           #{Magma.Obsidian.View.Helper.button("Select as draft version", "magma.artefact.select_draft", color: "blue")}

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
