defmodule Magma.Vault.Migration.V0_2 do
  @moduledoc false

  @target_version "0.2.0"

  alias Magma.Vault
  alias Magma.Matter.Project
  alias Mix.Tasks.Magma.Prompt.Update

  def migrate(%Version{major: 0, minor: 1}) do
    Mix.shell().info("Migrating vault to Magma v#{@target_version}")

    with {:ok, project} <- Project.concept(),
         :ok <- create_configs(),
         :ok <- update_custom_prompt_template(project),
         :ok <- update_prompts() do
      {:ok, @target_version}
    end
  end

  defp create_configs do
    Mix.shell().info("Step 1: Creating new config documents")

    with {:ok, project} <- Magma.Matter.Project.concept() do
      Vault.Initializer.create_config(project.subject.name)
    end
  end

  defp update_custom_prompt_template(project) do
    Mix.shell().info("Step 2: Update custom prompt template")

    Vault.Initializer.create_custom_prompt_template(project)

    :ok
  end

  defp update_prompts do
    Mix.shell().info("Step 3: Updating prompts")

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
