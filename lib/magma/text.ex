defmodule Magma.Text do
  alias Magma.Concept
  alias Magma.Matter
  alias Magma.Artefacts.TableOfContents

  def create(text_name, text_type)

  def create(text_name, text_type_name) when is_binary(text_type_name) do
    if text_type = Matter.Text.type(text_type_name) do
      create(text_name, text_type)
    else
      {:error, "unknown text type: #{text_type}"}
    end
  end

  def create(text_name, text_type) when is_binary(text_name) and is_atom(text_type) do
    if Matter.Text.type?(text_type) do
      with {:ok, concept} <- text_name |> text_type.new() |> Concept.create(),
           {:ok, _toc_prompt} <- TableOfContents.create_prompt(concept) do
        {:ok, concept}
      end
    else
      {:error, "invalid text type: #{text_type}"}
    end
  end
end
