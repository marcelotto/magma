---
magma_type: Artefact.Version
magma_artefact: ModuleDoc
magma_concept: "[[Mix.Tasks.Magma.Prompt.Exec]]"
magma_draft: "[[Generated ModuleDoc of Mix.Tasks.Magma.Prompt.Exec (2023-11-02T17:48:55)]]"
created_at: 2023-11-02 17:50:59
tags: [magma-vault]
aliases: []
---

>[!caution]
>Ensure that the module documentation is under a "Moduledoc" section, as the contents of this section is used for the `@moduledoc`.
>
>Note, that the function docs are not used automatically. They are just suggestions for improvements and must be applied manually.

# ModuleDoc of Mix.Tasks.Magma.Prompt.Exec

## Moduledoc

A Mix task for executing prompts.

This Mix task facilitates the execution of a given prompt either manually or according to the generation specification embedded within the prompt document, depending on the `magma_generation_type` and `magma_generation_params` properties specified in the YAML frontmatter.

The task can be invoked with a prompt name or path, like so:

```sh
$ mix magma.prompt.exec "Name of prompt"
```

Using the `--manual` switch allows for manual execution of the prompt. In this mode, the rendered prompt is copied to the clipboard, ready for pasting and executing in the LLM interface of one's choice. By default, the user is interactively asked to paste the result of this execution, which is then used to create a prompt result document:

```sh
$ mix magma.prompt.exec "Name of prompt" --manual
```

The `--no-interactive` switch disables the interactive prompt for pasting the result back and instead creates an empty prompt result document. This is useful in contexts where shell interaction is not possible, such as with Obsidian buttons.

### Configuration

The default values for the generation specification embedded within the prompt document (the `magma_generation_type` and `magma_generation_params` properties in its YAML frontmatter) can be configured for your application in `config.exs` like this

```elixir
config :magma,  
  default_generation: Magma.Generation.OpenAI
  
config :magma, Magma.Generation.OpenAI,  
  model: "gpt-4",  
  temperature: 0.6
```


### Command line options

- `--manual` - Executes the prompt manually, copying the rendered prompt to the clipboard for pasting and executing in an LLM interface
- `--no-interactive` - Disables the interactive prompt for pasting the result back and creates an empty prompt result document instead
