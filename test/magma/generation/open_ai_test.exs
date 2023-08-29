defmodule Magma.Generation.OpenAITest do
  use Magma.TestCase
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  doctest Magma.Generation.OpenAI

  alias Magma.Generation

  @moduletag capture_log: true

  setup_all do
    HTTPoison.start()
    :ok
  end

  test "successful request" do
    use_cassette "openai/simple_example" do
      assert Generation.OpenAI.new!()
             |> Generation.OpenAI.execute(
               "Elixir is ...",
               "You are an assistent for the Elixir language and answer short in one sentence."
             ) ==
               {:ok,
                "a dynamic, functional programming language designed for building scalable and maintainable applications."}
    end
  end

  test "without quota" do
    use_cassette "openai/without_quota" do
      # TODO: Should this produce a more specific error?
      assert Generation.OpenAI.new!()
             |> Generation.OpenAI.execute(
               "Elixir is ...",
               "You are an assistent for the Elixir language and answer short in one sentence."
             ) ==
               {
                 :error,
                 %{
                   "error" => %{
                     "type" => "insufficient_quota",
                     "code" => "insufficient_quota",
                     "message" =>
                       "You exceeded your current quota, please check your plan and billing details.",
                     "param" => nil
                   }
                 }
               }
    end
  end
end
