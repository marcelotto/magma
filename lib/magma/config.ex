defmodule Magma.Config do
  use GenServer

  defstruct [:system, :matter, :artefacts]

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
    GenServer.call(__MODULE__, {:system, key})
  end

  @impl true
  @spec init(any()) :: {:ok, t()}
  def init(_) do
    {:ok, %__MODULE__{}, {:continue, nil}}
  end

  @impl true
  def handle_continue(_, config) do
    case with_cached_system_config(config) do
      {:ok, config} -> {:noreply, config}
      {:error, _} -> {:noreply, config}
    end
  end

  @impl true
  def handle_call({:system, key}, _from, config) do
    case with_cached_system_config(config) do
      {:ok, config} -> {:reply, get_system(config, key), config}
      {:error, error} -> {:stop, error, config}
    end
  end

  defp with_cached_system_config(%{system: nil} = config) do
    with {:ok, system} <- Magma.Config.System.load() do
      {:ok, %__MODULE__{config | system: system}}
    end
  end

  defp with_cached_system_config(%__MODULE__{} = config), do: {:ok, config}

  defp get_system(%{system: system}, nil), do: system.custom_metadata
  defp get_system(%{system: system}, key), do: system.custom_metadata[key]
end
