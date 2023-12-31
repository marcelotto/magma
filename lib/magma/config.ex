defmodule Magma.Config do
  @moduledoc """
  Cache for the vault-based configuration.

  This singleton GenServer provides access to the cached
  `Magma.Config.Document`s in the `Magma.Vault`.
  """

  use GenServer

  defstruct [:system, :project, :matter, :artefacts, :text_types]

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

  @matter_path "matter"

  @doc """
  Returns the path with `Magma.Config.Matter` documents in the vault.
  """
  def matter_path, do: path(@matter_path)

  @doc """
  Constructs a complete path to a matter config document by joining the specified `segments` to the `matter_path/0`.
  """
  def matter_path(segments), do: Path.join([matter_path() | List.wrap(segments)])

  @artefacts_path "artefacts"

  @doc """
  Returns the path with `Magma.Config.Artefact` documents in the vault.
  """
  def artefacts_path, do: path(@artefacts_path)

  @doc """
  Constructs a complete path to a artefact config document by joining the specified `segments` to the `artefacts_path/0`.
  """
  def artefacts_path(segments), do: Path.join([artefacts_path() | List.wrap(segments)])

  @text_types_path "text_types"

  @doc """
  Returns the path with `Magma.Config.TextType` documents in the vault.
  """
  def text_types_path, do: path(@text_types_path)

  @doc """
  Constructs a complete path to a text type config document by joining the specified `segments` to the `text_types_path/0`.
  """
  def text_types_path(segments), do: Path.join([text_types_path() | List.wrap(segments)])

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

  @doc """
  Returns the `Magma.Project` document or a property of it.
  """
  def project(key \\ nil) do
    GenServer.call(__MODULE__, {:cached, :project, key})
  end

  @doc """
  Returns a `Magma.Config.Matter` document or a property of it.
  """
  def matter(type, key \\ nil) do
    GenServer.call(__MODULE__, {:cached, :matter, type, key})
  end

  @doc """
  Returns a `Magma.Config.Artefact` document or a property of it.
  """
  def artefact(type, key \\ nil) do
    GenServer.call(__MODULE__, {:cached, :artefacts, type, key})
  end

  @doc """
  Returns a `Magma.Config.TextType` document or a property of it.
  """
  def text_type(type, key \\ nil) do
    GenServer.call(__MODULE__, {:cached, :text_types, type, key})
  end

  @doc """
  Returns a list of all text types.
  """
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
      case init_matter(config) do
        {:ok, config} -> config
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

  defp load_document(:matter, type) do
    type |> Magma.Config.Matter.name_by_type() |> Magma.Config.Matter.load()
  end

  defp load_document(:artefacts, type) do
    type |> Magma.Config.Artefact.name_by_type() |> Magma.Config.Artefact.load()
  end

  defp load_document(:text_types, type) do
    type |> Magma.Config.TextType.name_by_type() |> Magma.Config.TextType.load()
  end

  defp initialized_documents(:matter, %{matter: nil} = config) do
    with {:ok, config} <- init_matter(config) do
      {:ok, config.matter, config}
    end
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
       when document_type in [:matter, :artefacts, :text_types] do
    {:ok, Map.get(config, document_type), config}
  end

  defp initialized_documents(invalid, _), do: invalid_config_document_type(invalid)

  defp invalid_config_document_type(invalid) do
    raise "invalid config document type: #{inspect(invalid)}"
  end

  defp init_matter(config) do
    with {:ok, files} <- File.ls(matter_path()) do
      {:ok,
       %__MODULE__{
         config
         | matter:
             files
             |> Enum.map(
               &(&1
                 |> Path.basename(".matter.config.md")
                 |> Magma.Matter.type())
             )
             |> Enum.reject(&is_nil/1)
             |> Map.new(&{&1, nil})
       }}
    end
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
                 |> Path.basename(".artefact.config.md")
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
                 |> Path.basename(".text_type.config.md")
                 |> Magma.Matter.Text.type(false))
             )
             |> Map.new(&{&1, nil})
       }}
    end
  end
end
