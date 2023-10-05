defmodule Magma.Matter.Module do
  # We don't have any additional fields, since we can get everything
  # via the Elixir and Erlang reflection API from the module name
  use Magma.Matter

  alias Magma.Concept

  import Magma.Utils.Guards

  @type t :: %__MODULE__{}

  @relative_base_path "modules"

  @impl true
  def artefacts, do: [Magma.Artefacts.ModuleDoc]

  @impl true
  def new(name: name), do: new(name)

  def new(name) when is_binary(name) do
    Elixir |> Module.concat(name) |> new()
  end

  def new(module) when maybe_module(module) do
    {:ok, %__MODULE__{name: module}}
  end

  def new!(attrs) do
    case new(attrs) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  @impl true
  def relative_base_path(_), do: @relative_base_path

  @impl true
  def relative_concept_path(%__MODULE__{name: module} = matter) do
    [@relative_base_path | context_segments(module)]
    |> Path.join()
    |> Path.join("#{concept_name(matter)}.md")
  end

  defp context_segments(module) do
    module |> Module.split() |> List.delete_at(-1)
  end

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

  @impl true
  def concept_name(%__MODULE__{name: module}), do: inspect(module)

  @impl true
  def concept_title(%__MODULE__{name: module}), do: "`#{inspect(module)}`"

  @impl true
  def default_description(%__MODULE__{} = matter, _) do
    """
    What is a #{concept_title(matter)}?

    Your knowledge about the module, i.e. facts, problems and properties etc.
    """
    |> String.trim_trailing()
    |> View.Helper.comment()
  end

  @impl true
  def context_knowledge(%Concept{subject: %__MODULE__{name: module}}) do
    """
    #### Peripherally relevant modules

    #{context_modules_knowledge(module)}
    """
    |> String.trim_trailing()
  end

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
    ##### `#{inspect(module)}` #{matter |> concept_name() |> View.Helper.transclude("Description")}
    """
  end

  @impl true
  def prompt_concept_description_title(%__MODULE__{name: name}) do
    "Description of the module `#{inspect(name)}`"
  end

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

  def source_path(%__MODULE__{name: module}), do: source_path(module)

  def source_path(module) when maybe_module(module) do
    if Code.ensure_loaded?(module) and function_exported?(module, :__info__, 1) do
      if source = module.__info__(:compile)[:source], do: to_string(source)
    end
  end

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

  def ignore?(module) do
    if module_code = code(module) do
      module_code = String.trim_leading(module_code)

      String.starts_with?(module_code, @ignore_pragma) or
        ((Regex.match?(~r/\s@moduledoc (false|nil)\s/, module_code) or
            Regex.match?(~r/\s@moduledoc !"/, module_code)) and
           not String.starts_with?(module_code, @include_pragma))
    else
      true
    end
  end
end
