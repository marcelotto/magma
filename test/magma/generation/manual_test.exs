defmodule Magma.Generation.ManualTest do
  use Magma.TestCase

  doctest Magma.Generation.Manual

  alias Magma.{Generation, Prompt}

  test "shell interaction" do
    prompt =
      custom_artefact_prompt(
        "Elixir is ...",
        "You are an assistent for the Elixir language and answer short in one sentence."
      )

    answer = "awesome"

    send(self(), {:mix_shell_input, :prompt, answer})

    assert Generation.Manual.new!()
           |> Generation.Manual.execute(prompt) ==
             {:ok, answer}

    assert_receive {:mix_shell, :prompt, [_]}
  end

  test "without shell interaction" do
    prompt =
      custom_artefact_prompt(
        "Elixir is ...",
        "You are an assistent for the Elixir language and answer short in one sentence."
      )

    assert Generation.Manual.new!()
           |> Generation.Manual.execute(prompt, interactive: false) ==
             {:ok, ""}
  end

  @tag skip_in_ci: true
  test "prompt content is copied to clipboard" do
    system_prompt = "Elixir is ..."

    request_prompt =
      "You are an assistent for the Elixir language and answer short in one sentence."

    prompt =
      custom_artefact_prompt(
        system_prompt,
        request_prompt
      )

    answer = "awesome"

    send(self(), {:mix_shell_input, :prompt, answer})

    assert Generation.Manual.new!()
           |> Generation.Manual.execute(prompt) ==
             {:ok, answer}

    # Wait for input to flush
    :timer.sleep(100)

    assert Clipboard.paste() ==
             """
             # #{Prompt.Template.system_prompt_section_title()}

             #{system_prompt}

             # #{Prompt.Template.request_prompt_section_title()}

             #{request_prompt}
             """

    assert_receive {:mix_shell, :prompt, [_]}
  end
end
