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

  def copy_directory(source, target, _opts \\ []) do
    cmd = "cp -R #{source} #{target}"
    Mix.shell().info(cmd)
    Mix.shell().cmd(cmd)
  end

  def create_file(target, content, opts \\ []) do
    Mix.Generator.create_file(target, content, opts)
  end

  def save_file(target, content, opts \\ []) do
    Mix.shell().info([:green, "* saving ", :reset, Path.relative_to_cwd(target)])
    File.write(target, content, opts)
  end
end
