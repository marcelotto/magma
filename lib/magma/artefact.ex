defmodule Magma.Artefact do
  alias Magma.Concept
  alias __MODULE__

  @type t :: module

  @callback name(Concept.t()) :: binary

  @callback prompt_name(Concept.t()) :: binary

  @callback system_prompt_task(Concept.t()) :: binary

  @callback request_prompt_task(Concept.t()) :: binary

  @callback concept_section_title :: binary

  @callback concept_prompt_task_section_title :: binary

  @callback version_title(Artefact.Version.t()) :: binary

  @callback version_prologue(Artefact.Version.t()) :: binary | nil

  @callback trim_prompt_result_header? :: boolean

  @callback relative_base_path(Concept.t()) :: Path.t()

  @callback relative_prompt_path(Concept.t()) :: Path.t()

  @callback relative_version_path(Concept.t()) :: Path.t()

  @callback create_version(Artefact.Version.t(), keyword) ::
              {:ok, Path.t() | Artefact.Version.t()} | {:error, any} | nil

  defmacro __using__(opts) do
    matter_type = Keyword.fetch!(opts, :matter)

    quote do
      @behaviour Magma.Artefact
      alias Magma.Artefact

      def matter_type, do: unquote(matter_type)

      @impl true
      def concept_section_title, do: Artefact.type_name(__MODULE__)

      @impl true
      def concept_prompt_task_section_title, do: "#{concept_section_title()} prompt task"

      @impl true
      def prompt_name(%Concept{} = concept), do: "Prompt for #{name(concept)}"

      @impl true
      def relative_prompt_path(%Concept{} = concept) do
        concept
        |> relative_base_path()
        |> Path.join("#{prompt_name(concept)}.md")
      end

      @impl true
      def relative_version_path(%Concept{} = concept) do
        concept
        |> relative_base_path()
        |> Path.join("#{name(concept)}.md")
      end

      @impl true
      def version_title(%Artefact.Version{artefact: __MODULE__} = version), do: version.name

      @impl true
      def version_prologue(%Artefact.Version{artefact: __MODULE__}), do: nil

      @impl true
      def trim_prompt_result_header?, do: true

      @impl true
      def create_version(%Artefact.Version{artefact: __MODULE__}, opts), do: nil

      def prompt(%Concept{subject: %unquote(matter_type){}} = concept, attrs \\ []) do
        Artefact.Prompt.new(concept, __MODULE__, attrs)
      end

      def prompt!(%Concept{subject: %unquote(matter_type){}} = concept, attrs \\ []) do
        Artefact.Prompt.new!(concept, __MODULE__, attrs)
      end

      def create_prompt(
            %Concept{subject: %unquote(matter_type){}} = concept,
            attrs \\ [],
            opts \\ []
          ) do
        Artefact.Prompt.create(concept, __MODULE__, attrs, opts)
      end

      def load_version(%Concept{} = concept) do
        concept
        |> name()
        |> Artefact.Version.load()
      end

      def load_version!(concept) do
        case load_version(concept) do
          {:ok, version} -> version
          {:error, error} -> raise error
        end
      end

      defoverridable prompt_name: 1,
                     version_prologue: 1,
                     trim_prompt_result_header?: 0,
                     relative_prompt_path: 1,
                     relative_version_path: 1,
                     version_title: 1,
                     create_version: 2
    end
  end

  @doc """
  Returns the artefact type name for the given artefact module.

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
  def type_name(type) do
    if type?(type) do
      case Module.split(type) do
        ["Magma", "Artefacts" | name_parts] -> Enum.join(name_parts, ".")
        _ -> raise "Invalid Magma.Artefacts type name scheme: #{inspect(type)}"
      end
    else
      raise "Invalid Magma.Artefacts type: #{inspect(type)}"
    end
  end

  @doc """
  Returns the artefact module for the given string.

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

  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :relative_prompt_path, 1)
  end
end
