defmodule Magma.Utils do
  @moduledoc !"Internal helper functions"

  @doc """
  Sets the field of a struct to a given value, unless it already has a value.
  """
  def init_field(struct, [{field, _}] = init) do
    if Map.get(struct, field) do
      struct
    else
      struct(struct, init)
    end
  end

  @doc """
  Sets the fields of a struct to  given values, unless they already have a value.
  """
  def init_fields(struct, fields) do
    Enum.reduce(fields, struct, &init_field(&2, List.wrap(&1)))
  end

  def map_while_ok(enum, fun) do
    with {:ok, mapped} <-
           Enum.reduce_while(enum, {:ok, []}, fn e, {:ok, acc} ->
             case fun.(e) do
               {:ok, value} -> {:cont, {:ok, [value | acc]}}
               error -> {:halt, error}
             end
           end) do
      {:ok, Enum.reverse(mapped)}
    end
  end

  def flat_map_while_ok(enum, fun) do
    with {:ok, mapped} <- map_while_ok(enum, fun) do
      {:ok, Enum.concat(mapped)}
    end
  end

  @doc """
  Converts all (string) map keys to atoms recursively.

  ## Examples

      iex> Magma.Utils.atomize_keys(%{"a" => 1, "b" => %{"c" => 3, "d" => 4}})
      %{a: 1, b: %{c: 3, d: 4}}
  """
  @spec atomize_keys(map) :: map
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
