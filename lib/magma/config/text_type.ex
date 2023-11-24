defmodule Magma.Config.TextType do
  use Magma.Config.Document, fields: [:label]

  @system_prompt_section "System prompt"
  def system_prompt_section, do: @system_prompt_section

  @impl true
  def title(%__MODULE__{name: name}), do: "#{name} text type config"

  @impl true
  def build_path(%__MODULE__{name: name}), do: {:ok, Magma.Config.text_types_path("#{name}.md")}

  def name_by_type(text_type), do: "#{Magma.Matter.Text.type_name(text_type, false)}.config"

  def type_name(%__MODULE__{name: name}), do: Path.basename(name, ".config")

  @impl true
  @doc false
  def load_document(%__MODULE__{} = document) do
    with {:ok, document} <- super(document) do
      {:ok,
       %__MODULE__{
         document
         | custom_metadata:
             Map.put_new(document.custom_metadata, :text_type_label, type_name(document))
       }}
    end
  end
end
