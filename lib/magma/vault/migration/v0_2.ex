defmodule Magma.Vault.Migration.V0_2 do
  @target_version "0.2.0"

  alias Magma.Vault
  alias Mix.Tasks.Magma.Prompt.Update

  def migrate(%Version{major: 0, minor: 1}) do
    Mix.shell().info("Migrating vault to Magma v#{@target_version}")

    with :ok <- create_configs(),
         :ok <- update_prompts() do
      :ok
    end
  end

  defp create_configs do
    Mix.shell().info("Step 1: Creating new config documents")

    with {:ok, project} <- Magma.Matter.Project.concept() do
      Vault.Initializer.create_config(project.subject.name)
    end
  end

  defp update_prompts do
    Mix.shell().info("Step 2: Updating prompts")

    if Mix.shell().yes?("""
       All parts of the prompts, which were previously hard-coded in the Magma source
       code are now part of the new config documents in your vault. In order to make
       use of them, the prompts need to be regenerated.
       We can do this automatically now or you can do this manually on your own later
       (with the "Update" button in the prompt documents or the `magma.prompt.update`
       Mix task), because you've added content to the prompt documents (which you
       shouldn't do) and you don't have the prompt documents under version control.
       Should we regenerate all prompts now automatically?
       """) do
      Update.update_all()
    else
      :ok
    end
  end
end
