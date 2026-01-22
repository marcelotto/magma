defmodule Magma.CLI.FileOps do
  @moduledoc """
  File operations abstraction replacing Mix.Generator functions.

  Provides file and directory operations with colored logging
  without depending on Mix infrastructure.
  """

  alias Magma.CLI.IO, as: CLI

  @doc """
  Creates a file with the given content.

  Returns `true` if the file was created/updated, `false` if skipped.

  ## Options

  - `:force` - forces creation without a shell prompt
  - `:quiet` - does not log command output
  """
  def create_file(path, contents, opts \\ []) when is_binary(path) do
    log(:green, :creating, Path.relative_to_cwd(path), opts)

    if opts[:force] || overwrite?(path, contents) do
      File.mkdir_p!(Path.dirname(path))
      File.write!(path, contents)
      true
    else
      false
    end
  end

  @doc """
  Creates a directory at the given path.

  ## Options

  - `:quiet` - does not log command output
  """
  def create_directory(path, opts \\ []) do
    log(:green, :creating, Path.relative_to_cwd(path), opts)
    File.mkdir_p!(path)
    true
  end

  @doc """
  Recursively copies a directory from source to target.

  Logs the operation.

  ## Options

  - `:quiet` - does not log command output
  """
  def copy_directory(source, target, opts \\ []) do
    source = Path.expand(source)
    target = Path.expand(target)

    dest = Path.join(target, Path.basename(source))

    log(
      :green,
      :copying,
      Path.relative_to_cwd(source) <> " to " <> Path.relative_to_cwd(target),
      opts
    )

    File.cp_r!(source, dest)
    :ok
  end

  @doc """
  Copies a single file from source to target.

  ## Options

  - `:force` - forces creation without a shell prompt
  - `:quiet` - does not log command output
  """
  def copy_file(source, target, opts \\ []) do
    create_file(target, File.read!(source), opts)
  end

  @doc """
  Saves a file with the given content, creating parent directories if needed.

  Uses "saving" prefix instead of "creating".
  """
  def save_file(path, content, opts \\ []) do
    path = Path.expand(path)

    log(:green, :saving, Path.relative_to_cwd(path), opts)

    File.mkdir_p!(Path.dirname(path))
    File.write(path, content, opts)
  end

  @doc """
  Prompts the user to overwrite the file if it exists.

  The contents are compared to avoid asking the user to
  override if the contents did not change. Returns `false`
  if the file exists and the content is the same or the
  user forbade to override it. Returns `true` otherwise.
  """
  def overwrite?(path, contents) do
    case File.read(path) do
      {:ok, binary} ->
        if binary == contents do
          false
        else
          full = Path.expand(path)
          CLI.yes?(Path.relative_to_cwd(full) <> " already exists, overwrite?")
        end

      _ ->
        true
    end
  end

  defp log(color, command, message, opts) do
    if !opts[:quiet] do
      CLI.info([color, "* #{command} ", :reset, message])
    end
  end
end
