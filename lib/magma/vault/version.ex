defmodule Magma.Vault.Version do
  @version_file ".VERSION"

  def file, do: Magma.Config.path(@version_file)

  def load do
    if File.exists?(file()) do
      file() |> File.read!() |> String.trim() |> Version.parse!()
    else
      Version.parse!("0.1.0")
    end
  end

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
