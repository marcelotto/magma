# Installation and setup

### in an existing Elixir project

First, the Magma Hex package must be setup as a development dependency in the `mix.exs` file of your project.

```elixir
def deps do
  [
    {:magma, "~> 0.1", only: [:dev, :test]}
  ]
end
```

Magma relies on Pandoc, so this needs to be installed. You'll need at least version 3.1.7. Refer to https://pandoc.org/installing.html for installation instructions.

To be able to open the Magma Vault in Obsidian, Obsidian should of course also be installed. A version >= 1.4 is strongly recommended, since links in the YAML frontmatter are used, which are only properly supported from version 1.4 on.

Although Magma also supports manual execution of LLM prompts for usage with ChatGPT, the best experience with more control over the execution is with the OpenAI API. For this, Magma uses the [Openai.ex](https://github.com/mgallo/openai.ex) package, which you have to add to your `mix.exs`. 

```elixir
def deps do
  [
    {:magma, "~> 0.1", only: [:dev, :test]},
    {:openai, "~> 0.5", only: [:dev]}
  ]
end
```

This requires also setting up your OpenAI API credentials in your `config.exs`. Since putting such credentials in a file under version control is not a good idea it is recommended to store them in environment variables and include those like this:

```elixir
config :openai,  
  api_key: {:system, "OPENAI_API_KEY"},  
  organization_key: {:system, "OPENAI_ORGANIZATION_KEY"},  
  http_options: [recv_timeout: 300_000]
```

You can set these environment variables in an `.envrc` file in your project directory:

```sh
# find it at https://platform.openai.com/account/api-keys  
export OPENAI_API_KEY=your-api-key
# find it at https://platform.openai.com/account/org-settings under "Organization ID"  
export OPENAI_ORGANIZATION_KEY=your-org-key
```

Note, that the default HTTP timeout was increased in the `config.exs`, which is strongly recommended, since the prompts in Magma can become quite large, resulting in rather lengthy executions esp. with the GPT-4 model. For more details on the configuration options of Openai.ex refer to its README.
