# Get Mix output sent to the current
# process to avoid polluting tests.
Mix.shell(Mix.Shell.Process)

ExUnit.start(exclude: System.get_env("CI") && [skip_in_ci: true])
