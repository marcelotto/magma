defmodule Magma.Utils do
  @doc """
  Converts all (string) map keys to atoms recursively.

  ## Examples

      iex> Magma.Utils.atomize_keys(%{"a" => 1, "b" => %{"c" => 3, "d" => 4}})
      %{a: 1, b: %{c: 3, d: 4}}
  """
  @spec atomize_keys(map :: Map.t()) :: Map.t()
  def atomize_keys(map) do
    Map.new(map, fn {key, value} ->
      {
        if(is_binary(key), do: String.to_atom(key), else: key),
        if(is_map(value), do: atomize_keys(value), else: value)
      }
    end)
  end

  @doc """
  Extracts the text between double square brackets.

  ## Examples

      iex> Magma.Utils.extract_link_text("[[Foo bar]]")
      "Foo bar"

      iex> Magma.Utils.extract_link_text("Foo bar")
      nil

  """
  def extract_link_text("[[" <> string) do
    String.slice(string, 0..-3)
  end

  def extract_link_text(_), do: nil
end
