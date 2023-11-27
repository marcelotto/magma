defmodule Magma.Text do
  alias Magma.Concept
  alias Magma.Matter
  alias Magma.Matter.Texts.Generic

  def create(text_name, text_type \\ nil)

  def create(text_name, nil), do: create(text_name, Generic)

  def create(text_name, text_type_name) when is_binary(text_type_name) do
    if text_type = Matter.Text.type(text_type_name) do
      create(text_name, text_type)
    else
      {:error, "unknown text type: #{text_type}"}
    end
  end

  def create(text_name, text_type) when is_binary(text_name) and is_atom(text_type) do
    if Matter.Text.type?(text_type) do
      with {:ok, text_matter} <- Matter.Text.new(text_name, type: text_type),
           {:ok, concept} <- Concept.create(text_matter) do
        {:ok, concept}
      end
    else
      {:error, "invalid text type: #{text_type}"}
    end
  end
end
