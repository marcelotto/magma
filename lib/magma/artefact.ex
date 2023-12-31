defmodule Magma.Artefact do
  @moduledoc """
  `Magma.Artefact` is a behaviour for defining different types of artefacts.

  A Magma artefact represents a specific type of output that can be generated
  for some Magma matter. The module provides a set of callbacks for specifying
  various aspects of the artefacts such as naming, path definitions, and
  document generation details.
  """

  alias Magma.{Concept, View}
  alias __MODULE__

  @fields [:name, :concept]
  def fields, do: @fields

  @type t :: struct

  @type type :: module

  @doc """
  A callback that returns the name of an artefact to be used as default for the `:name` field.
  """
  @callback default_name(Concept.t()) :: binary | nil

  @doc """
  A callback that returns the name of the `Magma.Artefact.Prompt` document for this type of matter.
  """
  @callback prompt_name(t()) :: binary

  @doc """
  A callback that returns the system prompt text of the `Magma.Artefact.Prompt` document for this type of matter that describes what to generate.

  As opposed to the `c:request_prompt_task/1` this is a general, static text
  used by artefacts of this type.

  The generated default implementation returns a transclusion of the
  "System prompt" section of the respective artefact config document.
  """
  @callback system_prompt_task(Concept.t()) :: binary

  @doc """
  A callback that returns the request prompt text of the `Magma.Artefact.Concept` document for this type of matter that describes what to generate.

  Despite returning also a general text like the `c:system_prompt_task/1`, this
  one is included in the "Artefacts" section of the `Magma.Concept` document
  (and only transcluded in `Magma.Artefact.Prompt` document), so that the user
  has a chance to adapt it for a specific instance of this artefact type.

  The generated default implementation returns the content of the
  "Task prompt" section of the respective artefact config document,
  after EEx evaluation with the bindings returned by `c:request_prompt_task_template_bindings/1`.
  """
  @callback request_prompt_task(Concept.t()) :: binary

  @doc """
  A callback that returns the bindings to be applied when rendering the `c:request_prompt_task/1` EEx template.
  """
  @callback request_prompt_task_template_bindings(Concept.t()) :: keyword

  @doc """
  A callback that returns the title of the "Artefacts" subsection for this type of matter in the `Magma.Concept` document.

  This section consists of links to the `Magma.Artefact.Prompt` and the
  `Magma.Artefact.Version` of this document and another subsection for the
  text returned by the `c:request_prompt_task/1` callback.
  """
  @callback concept_section_title :: binary

  @doc """
  A callback that returns the title of the "Artefacts" subsection for this type of matter in the `Magma.Concept` document where for the text returned by the `c:request_prompt_task/1` callback is rendered.

  By default, this is just the `concept_section_title/0` with `"prompt task"` appended.
  """
  @callback concept_prompt_task_section_title :: binary

  @doc """
  A callback that allows to specify texts which should be included generally in the "Context knowledge" section of the `Magma.Artefact.Prompt` document about this type of artefact.
  """
  @callback context_knowledge(Concept.t()) :: binary | nil

  @doc """
  A callback that returns the title to be used for the `Magma.Artefact.Version` document.
  """
  @callback version_title(Artefact.Version.t()) :: binary

  @doc """
  A callback that allows to specify a text which should be included in the prologue of the `Magma.Artefact.Version` document of this artefact type.
  """
  @callback version_prologue(Artefact.Version.t()) :: binary | nil

  @doc """
  A callback that returns if the initial header of a generated `Magma.PromptResult` for this type artefact should be stripped.

  Since the title for the `Magma.PromptResult` is already defined,
  the title generated by an LLM should be ignored usually.
  For some types of artefacts, however, this should not be the case.
  These artefact types, the default implementation returning `true`,
  can be overwritten.
  """
  @callback trim_prompt_result_header? :: boolean

  @doc """
  A callback that returns the general path segment to be used for documents for this type of artefact.
  """
  @callback relative_base_path(t()) :: Path.t()

  @doc """
  A callback that returns the path for `Magma.Artefact.Prompt` documents about this type of artefact.

  Since the `Magma.PromptResult` document are always stored in the subdirectory
  where the prompt are stored, this function also determines their path.

  This path is relative to the `Magma.Vault.artefact_generation_path/0`.
  """
  @callback relative_prompt_path(t()) :: Path.t()

  @doc """
  A callback that returns the path for `Magma.Artefact.Version` documents about this type of artefact.

  This path is relative to the `Magma.Vault.artefact_version_path/0`.
  """
  @callback relative_version_path(t()) :: Path.t()

  @doc """
  A callback that creates a new instance of a type of artefact with the default name.
  """
  @callback new(Concept.t()) :: {:ok, t()} | {:error, any}

  @doc """
  A callback that creates a new instance of a type of artefact.
  """
  @callback new(Concept.t(), keyword) :: {:ok, t()} | {:error, any}

  @doc """
  A callback that allows to implement a custom `Magma.Artefact.Version` document creation function.

  This function should return `nil` if the default `Magma.Artefact.Version.create/2`
  should be used (which the default implementation does automatically).
  """
  @callback create_version(Artefact.Version.t(), keyword) ::
              {:ok, Path.t() | Artefact.Version.t()} | {:error, any} | nil

  defmacro __using__(opts) do
    matter_type = Keyword.fetch!(opts, :matter)
    additional_fields = Keyword.get(opts, :fields, [])

    quote do
      @behaviour Magma.Artefact
      alias Magma.Artefact

      defstruct Artefact.fields() ++ unquote(additional_fields)

      def matter_type, do: unquote(matter_type)

      def config do
        Magma.Config.artefact(__MODULE__)
      end

      def config(key) do
        Magma.Config.artefact(__MODULE__, key)
      end

      def config_name do
        Magma.Config.Artefact.name_by_type(__MODULE__)
      end

      @impl true
      def concept_section_title, do: Artefact.type_name(__MODULE__)

      @impl true
      def concept_prompt_task_section_title, do: "#{concept_section_title()} prompt task"

      @impl true
      def prompt_name(%__MODULE__{name: name}), do: "Prompt for #{name}"

      @impl true
      def relative_prompt_path(%__MODULE__{} = artefact) do
        artefact
        |> relative_base_path()
        |> Path.join("#{prompt_name(artefact)}.md")
      end

      @impl true
      def relative_version_path(%__MODULE__{name: name} = artefact) do
        artefact
        |> relative_base_path()
        |> Path.join("#{name}.md")
      end

      @impl true
      def version_title(%Artefact.Version{artefact: %__MODULE__{}} = version), do: version.name

      @impl true
      def version_prologue(%Artefact.Version{artefact: %__MODULE__{}}), do: nil

      @impl true
      def trim_prompt_result_header?, do: true

      @impl true
      def system_prompt_task(_concept) do
        View.transclude(config_name(), Magma.Config.Artefact.system_prompt_section_title())
      end

      @impl true
      def request_prompt_task(concept) do
        Magma.Config.Artefact.render_request_prompt(
          config(),
          request_prompt_task_template_bindings(concept)
        )
      end

      @impl true
      def request_prompt_task_template_bindings(concept) do
        [
          project:
            if(match?(%Magma.Matter.Project{}, concept.subject),
              do: concept,
              else: Magma.Config.project()
            ),
          concept: concept,
          subject: concept.subject
        ]
      end

      @impl true
      def context_knowledge(%Concept{}) do
        Magma.Config.Artefact.context_knowledge_transclusion(__MODULE__)
      end

      @impl true
      def new(concept, attrs \\ []) do
        with {:ok, attrs} <- attrs |> Keyword.get(:name) |> set_name_attr(concept, attrs) do
          {:ok, struct(__MODULE__, Keyword.put(attrs, :concept, concept))}
        end
      end

      def new!(concept, attrs \\ []) do
        case new(concept, attrs) do
          {:ok, artefact} -> artefact
          {:error, error} -> raise error
        end
      end

      defp set_name_attr(nil, concept, attrs) do
        if default_name = default_name(concept) do
          {:ok, Keyword.put(attrs, :name, default_name)}
        else
          {:error, "name missing on #{inspect(__MODULE__)}"}
        end
      end

      defp set_name_attr(name, _, attrs) when is_binary(name), do: {:ok, attrs}
      defp set_name_attr(name, _, _), do: {:error, "invalid name type: #{inspect(name)}"}

      @impl true
      def create_version(%Artefact.Version{artefact: %__MODULE__{}}, opts), do: nil

      defoverridable prompt_name: 1,
                     trim_prompt_result_header?: 0,
                     relative_prompt_path: 1,
                     relative_version_path: 1,
                     version_title: 1,
                     version_prologue: 1,
                     new: 1,
                     new: 2,
                     create_version: 2,
                     system_prompt_task: 1,
                     request_prompt_task: 1,
                     request_prompt_task_template_bindings: 1
    end
  end

  @doc """
  Returns the artefact type name for the given artefact type module.

  ## Example

      iex> Magma.Artefact.type_name(Magma.Artefacts.ModuleDoc)
      "ModuleDoc"

      iex> Magma.Artefact.type_name(Magma.Artefacts.Article)
      "Article"

      iex> Magma.Artefact.type_name(Magma.Vault)
      ** (RuntimeError) Invalid Magma.Artefacts type: Magma.Vault

      iex> Magma.Artefact.type_name(NonExisting)
      ** (RuntimeError) Invalid Magma.Artefacts type: NonExisting

  """
  def type_name(type, validate \\ true) do
    if not validate or type?(type) do
      case Module.split(type) do
        ["Magma", "Artefacts" | name_parts] -> Enum.join(name_parts, ".")
        _ -> raise "Invalid Magma.Artefacts type name scheme: #{inspect(type)}"
      end
    else
      raise "Invalid Magma.Artefacts type: #{inspect(type)}"
    end
  end

  @doc """
  Returns the artefact type module for the given string.

  ## Example

      iex> Magma.Artefact.type("ModuleDoc")
      Magma.Artefacts.ModuleDoc

      iex> Magma.Artefact.type("TableOfContents")
      Magma.Artefacts.TableOfContents

      iex> Magma.Artefact.type("Vault")
      nil

      iex> Magma.Artefact.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(Magma.Artefacts, string)

    if type?(module) do
      module
    end
  end

  @doc """
  Checks if the given `module` is a `Magma.Artefact` type module.
  """
  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :relative_prompt_path, 1)
  end

  def relative_prompt_path(%artefact_type{} = artefact) do
    artefact_type.relative_prompt_path(artefact)
  end

  def relative_version_path(%artefact_type{} = artefact) do
    artefact_type.relative_version_path(artefact)
  end

  @doc """
  Extracts an `Magma.Artefact` instance from YAML frontmatter metadata.

  The function attempts to retrieve the `magma_artefact` and
  `magma_concept` from the metadata. It returns a tuple containing
  the artefact (if found and valid), and the remaining metadata.
  """
  def extract_from_metadata(metadata) do
    {artefact_type_name, metadata} = Map.pop(metadata, :magma_artefact)
    {artefact_name, metadata} = Map.pop(metadata, :magma_artefact_name)
    {concept_link, metadata} = Map.pop(metadata, :magma_concept)

    cond do
      !artefact_type_name ->
        {:error, "magma_artefact missing"}

      !concept_link ->
        {:error, "magma_concept missing"}

      artefact_type = type(artefact_type_name) ->
        with {:ok, concept} <- Concept.load_linked(concept_link),
             {:ok, artefact} <- artefact_type.new(concept, name: artefact_name) do
          {:ok, artefact, metadata}
        end

      true ->
        {:error, "invalid magma_artefact type: #{artefact_type_name}"}
    end
  end

  def render_front_matter(%artefact_type{concept: concept, name: name}) do
    """
    magma_artefact: #{type_name(artefact_type)}
    magma_concept: "#{View.link_to(concept)}"
    #{if name && name != artefact_type.default_name(concept) do
      "magma_artefact_name: #{name}"
    end}
    """
    |> String.trim_trailing()
  end
end
