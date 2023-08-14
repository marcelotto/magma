defmodule Magma.Concept do
  use Magma.Document,
    fields: [
      # the thing the concept is about
      subject: nil
    ]

  @type t :: %__MODULE__{}

  @concept_path_prefix "__concepts__"

  alias Magma.Vault
  alias Magma.Matter

  @impl true
  def dependency, do: :subject

  @impl true
  def document_template(%__MODULE__{subject: %matter_type{}}), do: matter_type.concept_template()

  @impl true
  def build_path(%__MODULE__{subject: %matter_type{} = matter}) do
    {:ok, Vault.path([@concept_path_prefix, matter_type.concept_path(matter)])}
  end

  @impl true
  @doc false
  def load_document(%__MODULE__{} = document) do
    Document.load_front_matter_property(document, :magma_matter, :subject, fn matter_type ->
      matter_module = Module.concat(Matter, matter_type)

      {:ok, matter_module.new(document.name)}
    end)
  end
end
