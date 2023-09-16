defmodule Magma.Artefact do
  alias Magma.Concept

  @type t :: module

  @callback name(Concept.t()) :: binary

  @callback prompt_name(Concept.t()) :: binary

  @callback relative_base_path(Concept.t()) :: Path.t()

  @callback relative_prompt_path(Concept.t()) :: Path.t()

  @callback relative_version_path(Concept.t()) :: Path.t()

  defmacro __using__(opts) do
    matter_type = Keyword.fetch!(opts, :matter)

    quote do
      @behaviour Magma.Artefact
      alias Magma.Artefact

      def matter_type, do: unquote(matter_type)

      @impl true
      def prompt_name(%Concept{} = concept),
        do: "Prompt for #{name(concept)}"

      @impl true
      def relative_prompt_path(%Concept{} = concept) do
        concept
        |> relative_base_path()
        |> Path.join("#{prompt_name(concept)}.md")
      end

      @impl true
      def relative_version_path(%Concept{} = concept) do
        concept
        |> relative_base_path()
        |> Path.join("#{name(concept)}.md")
      end

      def prompt(%Concept{subject: %unquote(matter_type){}} = concept, attrs \\ []) do
        Artefact.Prompt.new(concept, __MODULE__, attrs)
      end

      def prompt!(%Concept{subject: %unquote(matter_type){}} = concept, attrs \\ []) do
        Artefact.Prompt.new!(concept, __MODULE__, attrs)
      end

      def create_prompt(
            %Concept{subject: %unquote(matter_type){}} = concept,
            attrs \\ [],
            opts \\ []
          ) do
        Artefact.Prompt.create(concept, __MODULE__, attrs, opts)
      end

      defoverridable prompt_name: 1, relative_prompt_path: 1, relative_version_path: 1
    end
  end

  @doc """
  Returns the artefact module for the given string.

  ## Example

      iex> Magma.Artefact.type("ModuleDoc")
      Magma.Artefacts.ModuleDoc

      iex> Magma.Artefact.type("Vault")
      nil

      iex> Magma.Artefact.type("NonExisting")
      nil

  """
  def type(string) when is_binary(string) do
    module = Module.concat(Magma.Artefacts, string)

    if Code.ensure_loaded?(module) and function_exported?(module, :relative_prompt_path, 1) do
      module
    end
  end
end
