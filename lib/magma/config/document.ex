defmodule Magma.Config.Document do
  @default_tags ["magma-config"]
  def default_tags, do: @default_tags

  @context_knowledge_section_title "Context knowledge"
  def context_knowledge_section_title, do: @context_knowledge_section_title

  defmacro __using__(opts) do
    additional_fields = [:sections | Keyword.get(opts, :fields, [])]

    quote do
      use Magma.Document, fields: unquote(additional_fields)

      @impl true
      @doc false
      def load_document(%__MODULE__{} = document) do
        with {:ok, document_struct} <- Magma.DocumentStruct.parse(document.content) do
          {:ok, %__MODULE__{document | sections: document_struct.sections}}
        end
      end

      defoverridable load_document: 1
    end
  end

  def init(document) do
    Magma.Document.init(document, tags: default_tags())
  end
end
