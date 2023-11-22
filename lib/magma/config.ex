defmodule Magma.Config do
  use GenServer

  defstruct [:system, :matter, :artefacts, :project]

  @type t :: %__MODULE__{}

  alias Magma.Vault

  @dir "magma.config"
  def path, do: Vault.path(@dir)
  def path(segments), do: Path.join([path() | List.wrap(segments)])

  def template_path, do: :code.priv_dir(:magma) |> Path.join(@dir)

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def system(key \\ nil) do
    GenServer.call(__MODULE__, {:cached, :system, key})
  end

  def project(key \\ nil) do
    GenServer.call(__MODULE__, {:cached, :project, key})
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
        {:ok, config} -> config
        {:error, _} -> config
      end

    config =
      case cached(config, :project) do
        {:ok, config} -> config
        {:error, _} -> config
      end

    {:noreply, config}
  end

  @impl true
  def handle_call({:cached, document_type, key}, _from, config) do
    case cached(config, document_type) do
      {:ok, config} -> {:reply, get(config, document_type, key), config}
      {:error, error} -> {:stop, error, config}
    end
  end

  defp cached(config, document_type) do
    if Map.get(config, document_type) do
      {:ok, config}
    else
      with {:ok, document} <- load_document(document_type) do
        {:ok, Map.put(config, document_type, document)}
      end
    end
  end

  defp load_document(:system), do: Magma.Config.System.load()
  defp load_document(:project), do: Magma.Matter.Project.concept()
  defp load_document(unknown), do: raise("invalid config document type: #{inspect(unknown)}")

  defp get(config, document_type, key \\ nil)
  defp get(config, document_type, nil), do: Map.get(config, document_type)
  defp get(config, document_type, key), do: get(config, document_type).custom_metadata[key]
end
