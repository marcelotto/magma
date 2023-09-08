defmodule Magma.Obsidian.View.Helper do
  def link_to(document, title \\ nil)
  def link_to(%_{name: name}, nil), do: "[[#{name}]]"
  def link_to(%_{name: name}, title), do: "[[#{name}|#{title}]]"

  def transclude(document, section \\ nil)
  def transclude(%_{name: name} = document, nil), do: transclude(document, name)
  def transclude(%_{name: name}, :all), do: "![[#{name}]]"
  def transclude(%_{name: name}, section), do: "![[#{name}##{section}]]"

  def button(label, command, opts \\ []) do
    """
    ```button
    name #{label}
    type command
    action Shell commands: Execute: #{command}
    color #{opts[:color] || "default"}
    ```
    """
    |> String.trim_trailing()
  end

  def delete_current_file_button do
    """
    ```button
    name Delete
    type command
    action Delete current file
    color red
    ```
    """
  end

  def yaml_list(list) do
    "[" <> (list |> List.wrap() |> Enum.join(", ")) <> "]"
  end

  def yaml_nested_map(map) do
    map |> Map.from_struct() |> Jason.encode!()
  end

  def prompt_results_table do
    """
    ```dataview
    TABLE
    	tags AS Tags,
    	magma_generation_type AS Generator,
    	magma_generation_params AS Params
    WHERE magma_prompt = [[]]
    ```
    """
  end
end
