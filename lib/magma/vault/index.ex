defmodule Magma.Vault.Index do
  @moduledoc false

  use GenServer

  alias Magma.Vault

  @table_name __MODULE__

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: @table_name)
  end

  @impl true
  @spec init(any()) :: {:ok, nil}
  def init(_) do
    :ets.new(@table_name, [:named_table, :set, :public, read_concurrency: true])

    index()

    {:ok, nil}
  end

  def get_document_path(name) do
    case :ets.lookup(@table_name, name) do
      [{_, path}] -> path
      [] -> nil
    end
  end

  def index do
    if File.exists?(path = Vault.path()) do
      do_index(path)
    end
  end

  defp do_index(path) do
    path
    |> File.ls!()
    |> Enum.each(fn entry ->
      path = Path.join(path, entry)

      cond do
        File.dir?(path) -> do_index(path)
        Path.extname(path) == ".md" -> add(path)
        true -> nil
      end
    end)
  end

  @spec add(Magma.Document.t()) :: :ok
  def add(%_document_type{name: name, path: path}) do
    add(name, path)
  end

  @spec add(Path.t()) :: :ok
  def add(path) when is_binary(path) do
    path
    |> Path.basename(Path.extname(path))
    |> add(path)
  end

  @spec add(binary, Path.t()) :: :ok
  def add(name, path) do
    :ets.insert(@table_name, {name, path})

    :ok
  end

  @spec rebuild :: :ok
  def rebuild do
    clear()
    index()
    :ok
  end

  @spec clear :: :ok
  def clear do
    :ets.delete_all_objects(@table_name)
    :ok
  end
end
