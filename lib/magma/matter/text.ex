defmodule Magma.Matter.Text do
  use Magma.Matter, fields: [:type]

  alias Magma.{Matter, Concept}

  @type t :: %__MODULE__{}

  @impl true
  def artefacts, do: [Magma.Artefacts.TableOfContents]

  @sections_section_title "Sections"
  def sections_section_title, do: @sections_section_title

  @relative_base_path "texts"
  @impl true
  def relative_base_path(%__MODULE__{} = text),
    do: Path.join(@relative_base_path, concept_name(text))

  @impl true
  def relative_concept_path(%__MODULE__{} = text) do
    text
    |> relative_base_path()
    |> Path.join("#{concept_name(text)}.md")
  end

  @impl true
  def concept_name(%__MODULE__{name: name}), do: name

  @impl true
  def concept_title(%__MODULE__{name: name}), do: name

  @impl true
  def default_description(%__MODULE__{name: name}, _) do
    """
    What should "#{name}" cover?
    """
    |> View.Helper.comment()
  end

  @impl true
  def custom_sections(%Concept{} = concept) do
    """
    # #{@sections_section_title}

    """ <>
      View.Helper.comment("""
      Don't remove or edit this section.
      The results of the generated table of contents will be copied to this place.
      """) <>
      """


      # Artefact previews

      """ <>
      Enum.map_join(
        Matter.Text.Section.artefacts(),
        "\n",
        &"- #{View.Helper.link_to_preview({concept, &1})}"
      )
  end

  @impl true
  def new(attrs) when is_list(attrs) do
    {:ok, struct(__MODULE__, attrs)}
  end

  def new(type, name) do
    new(name: name, type: type)
  end

  def new!(attrs) do
    case new(attrs) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  def new!(type, name) do
    case new(type, name) do
      {:ok, matter} -> matter
      {:error, error} -> raise error
    end
  end

  @impl true
  def extract_from_metadata(document_name, _document_title, metadata) do
    {magma_matter_text_type, remaining} = Map.pop(metadata, :magma_matter_text_type)

    cond do
      !magma_matter_text_type ->
        {:error, "magma_matter_text_type missing in #{document_name}"}

      text_type = type(magma_matter_text_type) ->
        with {:ok, matter} <- new(text_type, document_name) do
          {:ok, matter, remaining}
        end

      true ->
        {:error, "invalid magma_matter_text_type: #{magma_matter_text_type}"}
    end
  end

  def render_front_matter(%__MODULE__{} = text) do
    """
    #{super(text)}
    magma_matter_text_type: #{Magma.Matter.Text.type_name(text.type)}
    """
    |> String.trim_trailing()
  end

  @doc """
  Returns the text type name for the given text module.

  ## Example

      iex> Magma.Matter.Text.type_name(Magma.Matter.Texts.UserGuide)
      "UserGuide"

      iex> Magma.Matter.Text.type_name(Magma.Vault)
      ** (RuntimeError) Invalid Magma.Matter.Text type: Magma.Vault

      iex> Magma.Matter.Text.type_name(NonExisting)
      ** (RuntimeError) Invalid Magma.Matter.Text type: NonExisting

  """
  def type_name(type) do
    if type?(type) do
      case Module.split(type) do
        ["Magma", "Matter", "Texts" | name_parts] -> Enum.join(name_parts, ".")
        _ -> raise "Invalid Magma.Matter.Text type: #{inspect(type)}"
      end
    else
      raise "Invalid Magma.Matter.Text type: #{inspect(type)}"
    end
  end

  @doc """
  Returns the text type module for the given string.

  ## Example

      iex> Magma.Matter.Text.type("UserGuide")
      Magma.Matter.Texts.UserGuide

      iex> Magma.Matter.Text.type("Vault")
      nil

      iex> Magma.Matter.Text.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(Magma.Matter.Texts, string)

    if type?(module) do
      module
    end
  end

  def type?(module) do
    Code.ensure_loaded?(module) and function_exported?(module, :system_prompt, 1)
  end
end
