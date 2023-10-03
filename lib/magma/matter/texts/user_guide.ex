defmodule Magma.Matter.Texts.UserGuide do
  use Magma.Matter.Text.Type

  alias Magma.{Concept, Matter}

  @impl true
  def label, do: "User guide"

  @impl true
  def system_prompt_task(%Concept{subject: %Matter.Text{} = text_matter}) do
    system_prompt_task(text_matter)
  end

  def system_prompt_task(%Concept{subject: %Matter.Text.Section{main_text: text_matter}}) do
    system_prompt_task(text_matter)
  end

  def system_prompt_task(%Matter.Text{type: __MODULE__, name: name}) do
    """
    Your task is to help write a user guide called "#{name}".

    The user guide should be written in English in the Markdown format.
    """
    |> String.trim_trailing()
  end
end
