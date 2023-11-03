<!-- ExDoc doesn't support YAML frontmatter

---
magma_type: Artefact.Version
magma_artefact: Article
magma_concept: "[[Magma User Guide - Installation and setup]]"
magma_draft: "[[Generated Magma User Guide - Installation and setup (article section) (2023-10-29T03:29:08)]]"
created_at: 2023-10-29 05:33:00
tags: [magma-vault]
aliases: []
---

-->

# Installation and setup

This section provides instructions on how to install and setup Magma within an Elixir project. 

> #### warning {: .warning}
>
> Please note that Magma has only been tested with MacOS so far. However, there is nothing that prevents it from running on other systems such as Windows and Linux. If you're a using these, please read [this issue](https://github.com/marcelotto/magma/issues/1).

Although primarily developed for Elixir projects, Magma can be useful in a variety of contexts. The following instructions assume you already have an Elixir project in which Magma will be installed. If you want to use Magma for general use cases, refer to the section, "Installation for non-Elixir devs" at the end.

## Installation in an existing Elixir project

Firstly, you need to set up the Magma Hex package as a development dependency in the `mix.exs` file of your project.

``` elixir
def deps do
  [
    {:magma, "~> 0.1", only: [:dev, :test]}
  ]
end
```

> #### warning {: .warning}
>
> If you're running on Apple Silicon you might experience problems with Rambo. You'll have to switch to the Github master version until the next version is released. See this issue: https://github.com/jayjun/rambo/pull/13#issuecomment-1193371511

Magma relies on Pandoc, which needs to be installed separately. Make sure you have at least version 3.1.7. Refer to the [Pandoc installation guide](https://pandoc.org/installing.html) for more details.

To open the Magma Vault in Obsidian, you must have Obsidian is installed of course. We recommend using version 1.4 or above as links in the YAML frontmatter are properly supported from this version onward.

For best experience and control over the execution, Magma uses the OpenAI API. This requires adding the [Openai.ex](https://github.com/mgallo/openai.ex) package to your `mix.exs`.

``` elixir
def deps do
  [
    {:magma, "~> 0.1", only: [:dev, :test]},
    {:openai, "~> 0.5", only: [:dev]}
  ]
end
```

You also need to set up your OpenAI API credentials in your `config.exs`. To avoid putting credentials in a file under version control, it is recommended to store them in environment variables as follows:

``` elixir
config :openai,  
  api_key: {:system, "OPENAI_API_KEY"},  
  organization_key: {:system, "OPENAI_ORGANIZATION_KEY"},  
  http_options: [recv_timeout: 300_000]
```

> #### warning {: .warning}
>
> The default HTTP timeout is increased here, which is strongly recommended as Magma prompts can become quite large, resulting in lengthy executions especially with the GPT-4 model. For more details on the configuration options of Openai.ex refer to its README.

You can set these environment variables in an `.envrc` file in your project directory:

```sh
# find it at https://platform.openai.com/account/api-keys  
export OPENAI_API_KEY=your-api-key
# find it at https://platform.openai.com/account/org-settings under "Organization ID"  
export OPENAI_ORGANIZATION_KEY=your-org-key
```

## Magma vault creation

Create a new Magma vault for your project with the `Mix.Tasks.Magma.Vault.Init` Mix task:

``` sh
$ mix magma.vault.init "Name of your project" [BaseVaultName]
```

You must specify a project name as the first mandatory parameter. As an optional second argument, you can specify the name of a BaseVault. A BaseVault is an Obsidian vault preconfigured with Obsidian themes and plugins. You can also specify the local path to a self-defined BaseVault. If no BaseVault is specified, the default BaseVault is used.

By default, a Magma vault is stored under the `docs.magma` directory within your project. This can be changed by configuring the `dir` application key of the `magma` app in `config.exs`:

``` elixir
config :magma,  
  dir: "your_magma_vault/"
```

> #### warning {: .warning}
>
> At the current state of the project, you can only change the name of directory here and not specify a completely separate directory outside of the Elixir project. This is not supported yet.

You can also configure a set of tags to be added on all generated documents with the `default_tags` key in your `config.exs`:

```elixir
config :magma,  
  default_tags: ["magma-vault"]
```

## Code sync

If you want to add documents for modules that were created after the initial vault creation, you can do so with the `Mix.Tasks.Magma.Vault.Sync.Code` Mix task:

``` sh
$ mix magma.vault.sync.code
```

A code sync creates corresponding documents for the generation of Magma artefacts for all public and non-ignored modules. A module is ignored if it has a `# Magma pragma: ignore` comment at the beginning of its source code, or if it is marked as hidden (e.g. with `@moduledoc false`) and does not have a `# Magma pragma: include` comment at the beginning of its source code file.

## Installation for non-Elixir devs

Firstly, install Erlang and Elixir following [this guide](https://elixir-lang.org/install.html).

Then navigate to the directory where you want to create the Magma vault with your Markdown files and run the following command with the name of the directory and change into this directory.

``` sh
$ mix new my_magma_vault
$ cd my_magma_vault
```

Now, you can continue with the "Installation in an existing Elixir project" above. Please note:

- After editing the deps in the `mix.exs` file, you need to fetch the specified dependencies: 
``` sh
$ mix deps.get
```
- Since you're not interested in documenting code, add the `--no-code-sync` option during vault initialization: 
``` sh
$ mix magma.vault.init "Name of your project" --no-code-sync
```
