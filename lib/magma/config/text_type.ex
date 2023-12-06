defmodule Magma.Config.TextType do
  @moduledoc """
  `Magma.Config.Document` for `Magma.Matter.Text` types.
  """

  use Magma.Config.Document, fields: [:text_type, :label]

  alias Magma.View

  @impl true
  def title(%__MODULE__{text_type: text_type}),
    do: "#{Magma.Matter.Text.type_name(text_type, false)} text type config"

  @system_prompt_section_title "System prompt"
  def system_prompt_section_title, do: @system_prompt_section_title

  @impl true
  def build_path(%__MODULE__{text_type: text_type}),
    do: {:ok, Magma.Config.text_types_path("#{name_by_type(text_type)}.md")}

  def name_by_type(text_type),
    do: "#{Magma.Matter.Text.type_name(text_type, false)}.text_type.config"

  def new(text_type_name, attrs \\ []) when is_binary(text_type_name) do
    {label, attrs} = Keyword.pop(attrs, :label)

    attrs =
      if label,
        do:
          Keyword.update(
            attrs,
            :custom_metadata,
            %{text_type_label: label},
            &Map.put(&1, :text_type_label, label)
          ),
        else: attrs

    struct(
      __MODULE__,
      Keyword.put(attrs, :text_type, Magma.Matter.Text.type(text_type_name, false))
    )
    |> Document.init_path()
  end

  def new!(text_type_name, attrs \\ []) do
    case new(text_type_name, attrs) do
      {:ok, document} -> document
      {:error, error} -> raise error
    end
  end

  def create(text_type_name, attrs \\ [], opts \\ [])

  def create(%__MODULE__{} = document, opts, []) do
    document
    |> Magma.Config.Document.init()
    |> render()
    |> Document.create(opts)
  end

  def create(%__MODULE__{}, _, _),
    do:
      raise(
        ArgumentError,
        "Magma.Config.TextType.create/3 is available only with an initialized document"
      )

  def create(text_type_name, attrs, opts) do
    with {:ok, document} <- new(text_type_name, attrs) do
      create(document, opts)
    end
  end

  defp render(document) do
    %__MODULE__{
      document
      | content: """
        # #{title(document)}

        ## #{@system_prompt_section_title}


        ## Context knowledge

        """
    }
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = document) do
    with {:ok, document} <- super(document) do
      {:ok,
       %__MODULE__{
         document
         | text_type: document |> type_name() |> Magma.Matter.Text.type(false)
       }}
    end
  end

  defp type_name(%__MODULE__{name: name}), do: Path.basename(name, ".text_type.config")

  def context_knowledge_transclusion(text_type) do
    text_type
    |> name_by_type()
    |> View.transclude(Magma.Config.Document.context_knowledge_section_title())
  end
end
