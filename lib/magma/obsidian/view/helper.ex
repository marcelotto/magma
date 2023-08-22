defmodule Magma.Obsidian.View.Helper do
  def link_to(document, title \\ nil)
  def link_to(%_{name: name}, nil), do: "[[#{name}]]"
  def link_to(%_{name: name}, title), do: "[[#{name}|#{title}]]"

  def transclude(document, section \\ nil)
  def transclude(%_{name: name} = document, nil), do: transclude(document, name)
  def transclude(%_{name: name}, :all), do: "![[#{name}]]"
  def transclude(%_{name: name}, section), do: "![[#{name}##{section}]]"

  def yaml_list(list) do
    "[" <> (list |> List.wrap() |> Enum.join(", ")) <> "]"
  end
end
