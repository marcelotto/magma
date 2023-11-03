<!-- ExDoc doesn't support YAML frontmatter

---
magma_type: Artefact.Version
magma_artefact: Article
magma_concept: "[[Magma User Guide - Custom Prompts and Prompt Execution]]"
magma_draft: "[[Generated Magma User Guide - Custom Prompts and Prompt Execution (article section) (2023-10-30T17:50:59)]]"
created_at: 2023-10-30 19:35:54
tags: [magma-vault]
aliases: []
---

-->


# Custom Prompts and Prompt Execution

Apart from the predefined prompts for the generation of specific artefacts discussed in the following sections, Magma also provides a feature to create and execute custom prompts. We start with them to introduce prompt execution, which also applies to the more involved artefact prompts.


## Creating a Custom Prompt

In Magma, you can create a custom prompt either via the Mix task `Mix.Tasks.Magma.Prompt.Gen`:

``` sh
$ mix magma.prompt.gen "Name of prompt"
```

or from within Obsidian using the command palette or the Cmd-Ctrl-P hotkey for the QuickAdd command "Custom Magma prompt". This triggers the same Mix task via the Obsidian ShellCommand plugin.

> #### warning {: .warning}
>
> Just like the name of any Obsidian document, the name of the prompt document must be unique. A good practice is to stick to a common naming scheme for prompts, e.g., "Prompt for ...", to ensure that the prompt documents never conflict with non-prompt documents.

This process creates a Magma prompt document, a special type of Magma document. It is saved in the `custom_prompt/` subdirectory of the Magma vault. 

> #### info {: .info}
> 
> Magma documents are Markdown files with a particular structure and semantic rules specific to Magma. 

Below is an example of a newly created custom prompt named "Example prompt":

``` markdown
---
magma_type: Prompt
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-22T14:14:57
tags: [magma-vault]
aliases: []
---

**Generated results**

``dataview
TABLE
    tags AS Tags,
    magma_generation_type AS Generator,
    magma_generation_params AS Params
WHERE magma_prompt = [[]]
``

**Actions**

``button
name Execute
type command
action Shell commands: Execute: magma.prompt.exec
color blue
``
``button
name Execute manually
type command
action Shell commands: Execute: magma.prompt.exec-manual
color blue
``
``button
name Copy to clipboard
type command
action Shell commands: Execute: magma.prompt.copy
color default
``

# Example prompt

## System prompt

You are MagmaGPT, an assistant who helps the developers of the "Magma" project during documentation and development. Your responses are in plain and clear English.

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Example project ![[Project#Description|]]


## Request

```

> #### warning {: .warning}
>
> To prevent problems with the Markdown processor, code blocks with three backticks are written in this guide using two backticks to maintain proper rendering. In the actual documents the code blocks are written correctly with three backticks.

The custom prompt document consists of several parts:

-   The YAML frontmatter includes several Magma-specific properties:
    -   `magma_type`: the Magma document type
    -   `magma_generation_type` and `magma_generation_params`: prompt-specific parameters for configuring the prompt execution
    -   `created_at`, `tags`, and `aliases`: standard Obsidian properties
-   The prologue (the text before the initial document title header) contains some document controls which require Obsidian to get rendered:
    -   A DataView table showing a list of the generated prompt results
    -   A series of buttons for different actions
-   The main body of the prompt contains two sections:
    -   "System prompt": This section becomes the system prompt of the OpenAI API request. It includes the persona and a "Context knowledge" subsection for providing background knowledge to the LLM.
    -   "Request": This section is where you write the actual prompt.

The persona used in all prompts can be customized for your application in the `config.exs` file:

``` elixir
config :magma,  
  persona: "Your custom persona"
```


The initial content of custom prompts can be customized with the Obsidian template in the directory `templates/custom_prompt.md` of the Magma vault. However, the basic structure of a "System prompt" and a "Request" section should remain unchanged.

## Writing a Custom Prompt

1. Unless you're working on a popular project the LLM has enough knowledge from its training, you should provide the basics of your project. So, ensure that a project description is provided in the "Description" section of the "Project" concept document. 
2.  Write your request in the "Request" section.
3.  Add more necessary background knowledge that the LLM needs to understand your request to the "Context knowledge" section. This is ideally done via transclusion of atomic notes.

## Executing the Prompt

Magma provides two ways to execute the prompt: automatic execution and manual execution. In both cases, the prompt result is saved in a separate prompt result document named after the original prompt with a timestamp. Like any prompt result it is placed in a subdirectory `__prompt_results__` of the directory where the prompt document is stored.

> #### info {: .info}
> 
> The Magma vault directory contains its own `.gitignore` file in which `__prompt_results__/` is listed by default, so they won't be version controlled.

### Manual Execution

Manual execution can be triggered from within Obsidian via the "Execute manually" button. This creates an empty prompt result document, which should show up in the "Generated results" table in the prologue and copies the compiled prompt with all transclusions resolved to the clipboard. The prompt from the clipboard can then be copied to the chatbot of your choice (ChaptGPT, Claude, Bard etc.), executed there and the result can be copied to the respective result document.

When executing manually via the `Mix.Tasks.Magma.Prompt.Exec` Mix task directly:

``` sh
$ mix magma.prompt.exec "Name of prompt" --manual
```

you are prompted on the shell to paste back the result, which is then added to the created prompt result document automatically. 

If you just want to execute the prompt and not save the result back into your vault, you can use the `Copy` button or the `Mix.Tasks.Magma.Prompt.Copy` Mix task:

``` sh
$ mix magma.prompt.copy "Name of prompt"
```

### Automatic Execution

Automatic execution is triggered via the "Execute" button or the `Mix.Tasks.Magma.Prompt.Exec` Mix task (without the `--manual` option).

In automatic execution, the `magma_generation_type` and `magma_generation_params` properties of the YAML frontmatter determine how the prompt is executed. The `magma_generation_type` determines which implementation of an LLM adapter (`Magma.Generation`) should be used. Currently, only the OpenAI API implementation (`Magma.Generation.OpenAI`) is available. The `magma_generation_params` set the values for the parameters of the selected adapter.

> #### warning {: .warning}
>
> Unfortunately, the property editor in Obsidian does not currently support editing JSON parameters. Therefore, you need to switch to source mode to edit `magma_generation_params` in Obsidian.

The prompt is then executed using the configured LLM adapter and its parameters, and the result is stored in a prompt result document upon completion. Execution can take several minutes, especially with GPT-4, which is highly recommended for its superior results. Completion is signaled by an Obsidian notification. If you are not satisfied with a prompt result, you can delete it using the "Delete" button in the prologue and try again with different parameters.

You can configure the default values for the `magma_generation_type` and `magma_generation_params` properties in `config.exs`:

``` elixir
config :magma,  
  default_generation: Magma.Generation.OpenAI
  
config :magma, Magma.Generation.OpenAI,  
  model: "gpt-4",  
  temperature: 0.6
```

The `default_generation` key sets the `Magma.Generation` adapter to be used for new prompt documents, while the configuration for the adapter sets the default values for the `magma_generation_params` property of new prompt documents. Note, that you can still adapt them there individually.
