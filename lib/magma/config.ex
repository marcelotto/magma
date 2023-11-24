defmodule Magma.Config do
  use GenServer

  defstruct [:system, :project, :matter, :artefacts, :text_types]

  @type t :: %__MODULE__{}

  alias Magma.Vault

  @dir "magma.config"
  def path, do: Vault.path(@dir)
  def path(segments), do: Path.join([path() | List.wrap(segments)])

  @artefacts_path "artefacts"
  def artefacts_path, do: path(@artefacts_path)
  def artefacts_path(segments), do: Path.join([artefacts_path() | List.wrap(segments)])

  @text_types_path "text_types"
  def text_types_path, do: path(@text_types_path)
  def text_types_path(segments), do: Path.join([text_types_path() | List.wrap(segments)])

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

  def artefact(type, key \\ nil) do
    GenServer.call(__MODULE__, {:cached, :artefacts, type, key})
  end

  def text_type(type, key \\ nil) do
    GenServer.call(__MODULE__, {:cached, :text_types, type, key})
  end

  def text_types do
    GenServer.call(__MODULE__, :text_types)
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

    config =
      case cached(config, :project) do
        {:ok, _, config} -> config
        {:error, _} -> config
      end

    config =
      case init_artefacts(config) do
        {:ok, config} -> config
        {:error, _} -> config
      end

    config =
      case init_text_types(config) do
        {:ok, config} -> config
        {:error, _} -> config
      end

    {:noreply, config}
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

  @impl true
  def handle_call({:cached, document_type, type, key}, _from, config) do
    case cached(config, document_type, type) do
      {:ok, document, config} ->
        {:reply, if(key == nil, do: document, else: document.custom_metadata[key]), config}

      {:error, error} ->
        {:stop, error, config}
    end
  end

  @impl true
  def handle_call(:text_types, _from, config) do
    case initialized_documents(:text_types, config) do
      {:ok, documents, config} ->
        {:reply, Map.keys(documents), config}

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

  defp cached(config, document_type, instance) do
    with {:ok, documents, config} <- initialized_documents(document_type, config) do
      if document = Map.get(documents, instance) do
        {:ok, document, config}
      else
        with {:ok, document} <- load_document(document_type, instance) do
          {:ok, document, Map.put(config, document_type, Map.put(documents, instance, document))}
        end
      end
    end
  end

  defp load_document(:system), do: Magma.Config.System.load()
  defp load_document(:project), do: Magma.Matter.Project.concept()
  defp load_document(invalid), do: invalid_config_document_type(invalid)

  defp load_document(:artefacts, type) do
    type |> Magma.Config.Artefact.name_by_type() |> Magma.Config.Artefact.load()
  end

  defp load_document(:text_types, type) do
    type |> Magma.Config.TextType.name_by_type() |> Magma.Config.TextType.load()
  end

  defp initialized_documents(:artefacts, %{artefacts: nil} = config) do
    with {:ok, config} <- init_artefacts(config) do
      {:ok, config.artefacts, config}
    end
  end

  defp initialized_documents(:text_types, %{text_types: nil} = config) do
    with {:ok, config} <- init_text_types(config) do
      {:ok, config.text_types, config}
    end
  end

  defp initialized_documents(document_type, config)
       when document_type in [:artefacts, :text_types] do
    {:ok, Map.get(config, document_type), config}
  end

  defp initialized_documents(invalid, _), do: invalid_config_document_type(invalid)

  defp invalid_config_document_type(invalid) do
    raise "invalid config document type: #{inspect(invalid)}"
  end

  defp init_artefacts(config) do
    with {:ok, files} <- File.ls(artefacts_path()) do
      {:ok,
       %__MODULE__{
         config
         | artefacts:
             files
             |> Enum.map(
               &(&1
                 |> Path.basename(".config.md")
                 |> Magma.Artefact.type())
             )
             |> Enum.reject(&is_nil/1)
             |> Map.new(&{&1, nil})
       }}
    end
  end

  defp init_text_types(config) do
    with {:ok, files} <- File.ls(text_types_path()) do
      {:ok,
       %__MODULE__{
         config
         | text_types:
             files
             |> Enum.map(
               &(&1
                 |> Path.basename(".config.md")
                 |> Magma.Matter.Text.type(false))
             )
             |> Map.new(&{&1, nil})
       }}
    end
  end
end
