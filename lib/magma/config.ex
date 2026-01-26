defmodule Magma.Config do
  @moduledoc """
  Cache for the vault-based configuration.

  This singleton GenServer provides access to the cached
  `Magma.Config.Document`s in the `Magma.Vault`.
  """

  use GenServer

  defstruct [:system]

  @type t :: %__MODULE__{}

  alias Magma.Vault

  @dir "magma.config"

  @doc """
  Returns the path with `Magma.Config.Document`s in the vault.
  """
  def path, do: Vault.path(@dir)

  @doc """
  Constructs a complete path to a config document by joining the specified `segments` to the `path/0`.
  """
  def path(segments), do: Path.join([path() | List.wrap(segments)])

  @doc """
  Returns the path with templates for the config document for a new vault.
  """
  def template_path, do: :code.priv_dir(:magma) |> Path.join(@dir)

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @doc """
  Resets the cache of all documents.
  """
  def reset do
    GenServer.cast(__MODULE__, :reset)
  end

  @doc """
  Returns the `Magma.Config.System` document or a property of it.
  """
  def system(key \\ nil) do
    GenServer.call(__MODULE__, {:cached, :system, key})
  end

  @impl true
  @spec init(any()) :: {:ok, t()}
  def init(_) do
    {:ok, %__MODULE__{}, {:continue, nil}}
  end

  @impl true
  def handle_continue(_, config) do
    config =
      case cached(config, :system) do
        {:ok, _, config} -> config
        {:error, _} -> config
      end

    {:noreply, config}
  end

  @impl true
  def handle_cast(:reset, _config) do
    {:noreply, %__MODULE__{}}
  end

  @impl true
  def handle_call({:cached, document_type, key}, _from, config) do
    case cached(config, document_type) do
      {:ok, document, config} ->
        {:reply, if(key == nil, do: document, else: document.custom_metadata[key]), config}

      {:error, error} ->
        {:stop, error, config}
    end
  end

  defp cached(config, document_type) do
    if document = Map.get(config, document_type) do
      {:ok, document, config}
    else
      with {:ok, document} <- load_document(document_type) do
        {:ok, document, Map.put(config, document_type, document)}
      end
    end
  end

  defp load_document(:system), do: Magma.Config.System.load()
  defp load_document(invalid), do: invalid_config_document_type(invalid)

  defp invalid_config_document_type(invalid) do
    raise "invalid config document type: #{inspect(invalid)}"
  end
end
