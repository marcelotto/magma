defmodule Magma.MixHelper do
  def with_valid_options(args, options_spec, fun) do
    case OptionParser.parse(args, strict: options_spec) do
      {opts, remaining, []} ->
        fun.(opts, remaining)

      {_opts, _remaining, invalid} ->
        """
        Invalid args: #{inspect(invalid)}

        Available options:

        #{Enum.map(options_spec, fn {opt, type} -> "- #{opt} : #{type}\n" end)}
        """
        |> Mix.shell().error()

      undefined ->
        raise "Undefined result: #{inspect(undefined)}"
    end
  end

  def copy_directory(source, target, _options \\ []) do
    cmd = "cp -R #{source} #{target}"
    Mix.shell().info(cmd)
    Mix.shell().cmd(cmd)
  end

  def copy_template(source, target, assigns) do
    Mix.Generator.copy_template(source, target, assigns)
    :ok
  end
end
