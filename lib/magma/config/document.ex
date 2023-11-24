defmodule Magma.Config.Document do
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
end
