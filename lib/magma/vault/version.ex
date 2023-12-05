defmodule Magma.Vault.Version do
  @moduledoc """
  Manages the versioning of the Magma vault.

  The `Magma.Vault.Version` module provides functionality to handle the
  versioning of the `Magma.Vault` by managing a version file within the vault.
  This is crucial for ensuring compatibility between the vault and the
  version of Magma being used, and for performing migrations when upgrading
  to a new version of Magma.
  """

  @version_file ".VERSION"

  @doc """
  Returns the path to the version file in the Magma vault.
  """
  def file, do: Magma.Config.path(@version_file)

  @doc """
  Loads and returns the Magma vault version from the version file.

  This function reads the version information from the `.VERSION` file within
  the Magma vault. If the version file exists, it parses the version string
  into a `Version` struct. If the file does not exist, it defaults to version
  "0.1.0".
  """
  def load do
    if File.exists?(file()) do
      file() |> File.read!() |> String.trim() |> Version.parse!()
    else
      Version.parse!("0.1.0")
    end
  end

  @doc """
  Saves the given version to the version file in the Magma vault.
  """
  def save(version)

  def save(version_string) when is_binary(version_string) do
    with {:ok, version} <- Version.parse(version_string) do
      save(version)
    end
  end

  def save(%Version{} = version) do
    File.write(file(), to_string(version))
  end
end
