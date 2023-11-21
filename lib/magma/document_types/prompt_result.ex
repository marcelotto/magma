defmodule Magma.PromptResult do
  use Magma.Document, fields: [:prompt, :generation]

  @type t :: %__MODULE__{}

  alias Magma.{Vault, Artefact, Generation, Prompt, View}
  alias Magma.Document.Loader

  import Magma.Utils, only: [init_field: 2]

  require Logger

  @impl true
  def title(%__MODULE__{prompt: %Prompt{} = prompt}) do
    "Prompt result of '#{prompt.name}'"
  end

  @impl true
  def title(%__MODULE__{prompt: %Artefact.Prompt{artefact: artefact}}) do
    "Generated #{artefact.name}"
  end

  def build_name(%__MODULE__{prompt: %Prompt{} = prompt} = result) do
    "#{prompt.name} (Prompt result #{NaiveDateTime.to_iso8601(result.created_at)})"
  end

  def build_name(%__MODULE__{} = result) do
    "#{title(result)} (#{NaiveDateTime.to_iso8601(result.created_at)})"
  end

  @impl true
  def build_path(%__MODULE__{prompt: %Prompt{}} = result) do
    {:ok,
     [Prompt.path_prefix(), "__prompt_results__", "#{build_name(result)}.md"]
     |> Vault.path()}
  end

  @impl true
  def build_path(%__MODULE__{prompt: %Artefact.Prompt{artefact: artefact}} = result) do
    {:ok,
     [
       artefact |> Artefact.relative_prompt_path() |> Path.dirname(),
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
    |> init_field(created_at: Document.now())
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
           |> Document.init(generation: document.prompt.generation || Generation.default())
           |> execute_prompt(opts),
         {:ok, document} <- Document.create(document, opts) do
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
      {:ok,
       %__MODULE__{
         document
         | content: render(document, post_process_result(document, result))
       }}
    end
  end

  defp post_process_result(document, result) do
    result
    |> String.trim_leading()
    |> trim_header(document)
    |> String.trim_trailing()
  end

  defp trim_header("#" <> _ = result, document) do
    if trim_header?(document) do
      case String.split(result, "\n", parts: 2) do
        [_, rest] -> String.trim_leading(rest)
        # It seems we're only getting just a header and nothing else, so we at least indent it.
        [only_header_result] -> "#" <> only_header_result
      end
    else
      result
    end
  end

  defp trim_header(result, _), do: result

  defp trim_header?(%__MODULE__{prompt: %Artefact.Prompt{artefact: %artefact_type{}}}) do
    artefact_type.trim_prompt_result_header?()
  end

  defp trim_header?(_), do: false

  defp render(prompt_result, execution_result) do
    """

    #{controls(prompt_result)}

    # #{title(prompt_result)}

    #{execution_result}
    """
  end

  def controls(%__MODULE__{prompt: %Prompt{}}) do
    View.delete_current_file_button()
  end

  def controls(%__MODULE__{prompt: %Artefact.Prompt{}} = prompt_result) do
    """
    #{View.button("Select as draft version", "magma.artefact.select_draft", color: "blue")}
    #{View.delete_current_file_button()}

    Final version: #{View.link_to_version(prompt_result)}

    #{View.callout("This document should be treated as read-only. If you want to make changes, select it as a draft and make your changes there.", :attention)}
    """
    |> String.trim_trailing()
  end

  @impl true
  def render_front_matter(%__MODULE__{} = document) do
    """
    magma_prompt: "#{View.link_to(document.prompt)}"
    #{Generation.render_front_matter(document.generation)}
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
end
