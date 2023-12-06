defmodule Magma.Config.Document do
  @moduledoc """
  Foundational behaviors for Magma configuration documents.

  This module is a base module that defines shared behavior and attributes for
  Magma configuration documents. It is used to ensure consistency and
  standardization of configuration documents.
  """

  @doc """
  Returns the default tags for Magma configuration documents.
  """
  @default_tags ["magma-config"]
  def default_tags, do: @default_tags

  @doc """
  The title for the context knowledge section in configuration documents.
  """
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

  @doc """
  Initializes a new Magma configuration document.
  """
  def init(document) do
    Magma.Document.init(document, tags: default_tags())
  end
end
