defmodule Magma.DocumentNotFound do
  @moduledoc """
  Represents a missing document that is referenced somewhere.
  """
  defexception [:name, :document_type]

  def message(%{document_type: nil, name: name}) do
    "Document #{name} not found"
  end

  def message(%{document_type: document_type, name: name}) do
    "#{inspect(document_type)} document #{name} not found"
  end
end

defmodule Magma.InvalidDocumentType do
  @moduledoc """
  Raised when a document type does not match the expected one.
  """
  defexception [:document, :expected, :actual]

  def message(%{document: document, expected: expected, actual: actual}) do
    "invalid document type of #{document}: expected #{inspect(expected)}, but got #{inspect(actual)}"
  end
end
