defmodule Magma.Matter.Module do
  @moduledoc """
  `Magma.Matter` type behaviour implementation for Elixir modules.

  The `Magma.Matter.Module` struct is used for generation of `Magma.Artefact`s
  about Elixir modules. It does not have any additional fields above the
  `Magma.Matter.fields/0` as it retrieves all necessary information via the
  Elixir and Erlang reflection API from the module name.
  """

  use Magma.Matter

  alias Magma.Concept

  import Magma.Utils.Guards

  @type t :: %__MODULE__{}

  @artefacts [Magma.Artefacts.ModuleDoc]

  @relative_base_path "modules"

  @doc """
  Returns the list of `Magma.Artefact` types available for Elixir modules.

      iex> Magma.Matter.Module.artefacts()
      #{inspect(@artefacts)}

  """
  @impl true
  def artefacts, do: @artefacts

  @doc """
  Creates a new `Magma.Matter.Module` instance from a given module name in an ok tuple.
  """
  @spec new(binary | atom | [name: binary | atom]) :: {:ok, t()} | {:error, any}
  def new(name: name), do: new(name)

  def new(name) when is_binary(name) do
    Elixir |> Module.concat(name) |> new()
  end

  def new(module) when maybe_module(module) do
    {:ok, %__MODULE__{name: module}}
  end

  @doc """
  Creates a new `Magma.Matter.Module` instance from a given module name and fails in error cases.
  """
  def new!(attrs) do
    case new(attrs) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  @doc """
  Returns the base path segment to be used for different kinds of documents for Elixir modules.

  The base path for all modules is `#{inspect(@relative_base_path)}`.
  """
  @impl true
  def relative_base_path(_), do: @relative_base_path

  @doc """
  Returns the path for `Magma.Concept` documents about Elixir modules.

  ### Example

      iex> Some.Module
      ...> |> Magma.Matter.Module.new!()
      ...> |> Magma.Matter.Module.relative_concept_path()
      "modules/Some/Some.Module.md"

  """
  @impl true
  def relative_concept_path(%__MODULE__{name: module} = matter) do
    [@relative_base_path | context_segments(module)]
    |> Path.join()
    |> Path.join("#{concept_name(matter)}.md")
  end

  defp context_segments(module) do
    module |> Module.split() |> List.delete_at(-1)
  end

  @doc """
  Returns a list of the modules the given `module` is defined under.

  ### Example

      iex> Magma.Matter.Module.context_modules(Magma.DocumentStruct.Section)
      [Magma, Magma.DocumentStruct]

  """
  def context_modules(module) do
    {result, _} =
      module
      |> context_segments()
      |> Enum.map_reduce(nil, fn module_segment, context ->
        module = Module.concat(context, module_segment)
        {module, module}
      end)

    result
  end

  @doc """
  Returns a list of the submodules defined under the given `module`.

  Note: This function relies on the existence of concept documents for modules.
  """
  def submodules(module) do
    {:ok, path} = module |> Module.concat(X) |> new!() |> Concept.build_path()
    module_path = Path.dirname(path)

    if File.exists?(module_path) do
      module_path
      |> File.ls!()
      |> Enum.filter(&(Path.extname(&1) == ".md"))
      |> Enum.map(&Module.concat(Elixir, &1 |> Path.basename(".md") |> String.to_atom()))
    end
  end

  @doc """
  Returns the name of the `Magma.Concept` document for an Elixir module.

  It is the module name as a string.

  ### Example

    iex> Some.Module
    ...> |> Magma.Matter.Module.new!()
    ...> |> Magma.Matter.Module.concept_name()
    "Some.Module"

  """
  @impl true
  def concept_name(%__MODULE__{name: module}), do: inspect(module)

  @doc """
  Returns the title header text of the `Magma.Concept` document for an Elixir module.

  ### Example

    iex> Some.Module
    ...> |> Magma.Matter.Module.new!()
    ...> |> Magma.Matter.Module.concept_title()
    "`Some.Module`"

  """
  @impl true
  def concept_title(%__MODULE__{name: module}), do: "`#{inspect(module)}`"

  @doc """
  Returns a default description for the `Magma.Concept` document of an Elixir module.
  """
  @impl true
  def default_description(%__MODULE__{} = matter, _) do
    """
    What is a #{concept_title(matter)}?

    Your knowledge about the module, i.e. facts, problems and properties etc.
    """
    |> View.comment()
  end

  @impl true
  def context_knowledge(%Concept{subject: %__MODULE__{name: module}} = concept) do
    if auto_module_context?() do
      """
      #{super(concept)}

      #### Peripherally relevant modules

      #{context_modules_knowledge(module)}
      """
      |> String.trim_trailing()
    end
  end

  defp auto_module_context?, do: config(:auto_module_context)

  defp context_modules_knowledge(module) do
    context_modules =
      case context_modules(module) do
        # ignore modules for Mix tasks
        [Mix | _] -> []
        context_modules -> context_modules
      end

    submodules = module |> submodules() |> List.wrap()

    Enum.map_join(context_modules ++ submodules, "\n", &context_module_knowledge/1)
  end

  defp context_module_knowledge(module) do
    matter = new!(module)

    """
    ##### `#{inspect(module)}` #{matter |> concept_name() |> View.transclude("Description")}
    """
  end

  @doc """
  Returns the title for the description section of the module in artefact prompts.

  ### Example

      iex> Some.Module
      ...> |> Magma.Matter.Module.new!()
      ...> |> Magma.Matter.Module.prompt_concept_description_title()
      "Description of the module `Some.Module`"

  """
  @impl true
  def prompt_concept_description_title(%__MODULE__{name: name}) do
    "Description of the module `#{inspect(name)}`"
  end

  @doc """
  Returns a string with a Markdown section containing the source code of the module for artefact prompts.
  """
  @impl true
  def prompt_matter_description(%__MODULE__{} = matter) do
    """
    ### Module code

    This is the code of the module to be documented. Ignore commented out code.

    ```elixir
    #{code(matter)}
    ```
    """
  end

  @doc """
  Returns the source path of the `module`, if it exists.

  The source path is the file path where the source code of the module is located.
  """
  @spec source_path(t() | module) :: Path.t() | nil
  def source_path(module)

  def source_path(%__MODULE__{name: module}), do: source_path(module)

  def source_path(module) when maybe_module(module) do
    if Code.ensure_loaded?(module) and function_exported?(module, :__info__, 1) do
      if source = module.__info__(:compile)[:source], do: to_string(source)
    end
  end

  @doc """
  Returns the source code of the module, if it exists.

  The source code is read from the `source_path/1`.
  """
  @spec code(t() | module | Path.t()) :: binary | nil
  def code(module)

  def code(%__MODULE__{name: module}), do: code(module)

  def code(module) when maybe_module(module) do
    if (source_path = source_path(module)) && File.exists?(source_path) do
      code(source_path)
    end
  end

  def code(path) when is_binary(path) do
    File.read!(path)
  end

  @ignore_pragma "# Magma pragma: ignore"
  @include_pragma "# Magma pragma: include"

  @doc """
  Determines whether the module should be ignored when generating documentation.

  A module is ignored

  - if it has a #{@ignore_pragma} comment at the beginning of its source code, or
  - if it is marked as hidden (e.g. with `@moduledoc false`) and does not have a
    #{@include_pragma} comment at the beginning of its source code.

  """
  def ignore?(module) do
    if module_code = code(module) do
      module_code = String.trim_leading(module_code)

      String.starts_with?(module_code, @ignore_pragma) or
        (hidden?(module) and not String.starts_with?(module_code, @include_pragma))
    else
      true
    end
  end

  defp hidden?(module) do
    match?(
      {_docs_v1, _annotation, _beam_language, _format, :hidden, _metadata, _docs},
      Code.fetch_docs(module)
    )
  end
end
