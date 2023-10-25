defmodule Magma.Matter.Texts.Generic do
  use Magma.Matter.Text.Type

  alias Magma.{Concept, Matter}

  @impl true
  def label, do: "Text"

  @impl true
  def system_prompt_task(%Concept{subject: %Matter.Text{} = text_matter}) do
    system_prompt_task(text_matter)
  end

  def system_prompt_task(%Concept{subject: %Matter.Text.Section{main_text: text_matter}}) do
    system_prompt_task(text_matter)
  end

  def system_prompt_task(%Matter.Text{type: __MODULE__, name: name}) do
    """
    Your task is to help write a text called "#{name}".
    """
    |> String.trim_trailing()
  end
end
