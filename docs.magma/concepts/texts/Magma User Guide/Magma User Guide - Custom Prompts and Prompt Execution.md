---
magma_type: Concept
magma_matter_type: Text.Section
magma_section_of: "[[Magma User Guide]]"
created_at: 2023-10-20 09:53:34
tags: [magma-vault]
aliases: []
---
# Custom Prompts and Prompt Execution

## TODO

## Description

Abstract: This section introduces the basics of prompt executions in Magma with  custom prompts. It provides examples and a step-by-step guide on how to create and use custom prompts.

A custom prompt in Magma can be created either via this Mix task `Mix.Tasks.Magma.Prompt.Gen`:

```sh
$ mix magma.prompt.gen "Name of prompt"
```

or from Obsidian via the command palette or the Cmd-Ctrl-P hotkey for the QuickAdd command "Custom Magma prompt" for a call of this Mix task (via a Obsidian ShellCommand). 

The name of the prompt must be (as any Obsidian and Magma document) unique. A good practice is to have a common naming scheme for prompts, e.g. "Prompt for ..." which ensures that at least the prompt documents never get in naming conflict with non-prompt documents.

This will create a Magma prompt document, one of the various kinds of Magma document types with a special semantics.

- [At this point Magma documents should be introduced in general as Markdown documents with a special semantics for Magma.]

It is saved in the `custom_prompt/` subdirectory of the Magma vault.

Here's a freshly created custom prompt named "Example prompt" (the code block backticks had to be escaped):

```markdown
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

Side-note: The prevent problems with the Markdown processor, code blocks with three backticks are displayed using two backticks to maintain proper rendering.

Details of the structure and content of a custom prompt:

- first the YAML frontmatter with some Magma specific properties 
	- `magma_type`: the Magma document type
	- `magma_generation_type` and `magma_generation_params` are prompt-specific  params for configuring the prompt execution (described below)
	- the `created_at`, `tags` and `aliases` properties are the usual Obsidian properties
		- Note, that the default tag `magma-vault` was added as configured in the "Installation and setup" section.
- then follows the prologue (this is how the text before the initial document title header is called in Magma)
	- in case of a prompt document it contains:
		- a DataView table with a list of the generated prompt results (rendered in Obsidian only)
		- a series of buttons (rendered in Obsidian only)
			- the "Execute" button executes the `magma.prompt.exec` Mix task on this prompt to execute the prompt with the settings from `magma_generation_type` and `magma_generation_params` properties of the YAML frontmatter
			- the "Execute manually" button executes the `magma.prompt.exec` Mix task with the `--manual` option on this prompt to execute the prompt manual (as described below)
			- the "Copy" button executes the `magma.prompt.copy` Mix task with the on this prompt to copy the compiled prompt with transclusions resolved to the clipboard
- then, after the document title header with the prompt name, follows the main body of the prompt consisting of two sections
	- "System prompt": The content of this section becomes the system prompt of the OpenAI API request (section levels shifted accordingly). It contains 
		- the persona either default persona or the application configured one
		```elixir
		config :magma,  
		  persona: "Your custom persona"
		```
		- a Context knowledge base subsection for background knowledge needed for the LLM to create a proper response, i.e. information it does not know either because of the knowledge cut-off date or unpublished knowledge.
			- by this section transcludes the project description from the project concept document
	- "Request": this section finally is for the content of your prompt

Side-note: The content of the custom prompt can be customized with the Obsidian template in the directory `templates/custom_prompt.md` of the Magma vault. However, the basic structure of a "System prompt" and a "Request" section should remain unchanged.

Workflow for writing a custom prompt:

- If not done already: provide a project description in the "Description" section of the "Project" concept document (more on concept documents in the next section).
- Add the necessary background knowledge the LLM needs to understand your request to context knowledge to "Context knowledge section"; ideally via transclusion of an atomic note.
- Write the actual request in resp. section.

There two ways to execute the prompt:

- Automatic Execution via the "Execute" button 
- Manual execution via the "Execute manually" button
	- or the Mix task executes the `magma.prompt.exec` Mix task with the `--manual` option

In both cases the prompt result will be saved in a separate PromptResult Magma document named after the original prompt with a timestamp (e.g. in our example `Example prompt (Prompt result 2023-10-23T04:52:21)`)  in the directory `custom_prompts/__prompt_results__/`.


### Manual execution

Manual execution works like this

- an empty prompt result document is created, which should show up in the "Generated results" table in the prologue
- the compiled prompt with all transclusions resolved is copied to the clipboard
- The clipboard can now be copied to the chatbot of your choice (ChaptGPT, Claude, Bard etc.), executed there and the result can be copied to the respective result document.

When manual execution is done via the `Mix.Tasks.Magma.Prompt.Exec` Mix task directly like this

```sh
$ mix magma.prompt.exec "Name of prompt" --manual
```

you're prompted on the shell to paste back the result (unless this disable is disabled with the option `--no-interactive`), which is added in the created the prompt result.

If you just want to execute the prompt and not save the result back into your vault, you can just copy the compiled prompt with the `Copy` button or the `Mix.Tasks.Magma.Prompt.Copy` Mix task:

```sh
$ mix magma.prompt.copy "Name of prompt"
```

### Automatic Execution

When executing automatically via the "Execute" button or the `magma.prompt.exec` Mix task (without the `--manual` option), the `magma_generation_type` and `magma_generation_params` properties of the YAML frontmatter determine the execution:  
  
- `magma_generation_type`: determines which implementation of an LLM adapter (`Magma.Generation`) should be used; however, currently there is only one implementation for the OpenAI API (`Magma.Generation.OpenAI`)  
- `magma_generation_params`: determines the values for the parameters of the adapter configured with `magma_generation_type` as JSON object  
	- the `Magma.Generation.OpenAI` adapter currently supports only the two parameters `model` and `temperature` (see the [OpenAI API documentation](https://platform.openai.com/docs/) for details)   
	- Side note: Unfortunately, the property editor in Obsidian does not currently support editing JSON parameters. Therefore, it is necessary to switch to source mode to be able to edit `magma_generation_params` in Obsidian.  
  
Using the configured LLM adapter and its parameters, the prompt is then executed and the result is stored in a PromptResult Magma document upon completion.  
  
- Note: Execution can take several minutes, especially with the GPT-4, which is highly recommended due to its much better results. Completion is signaled by an Obsidian notification.  
- If you are not satisfied with a prompt result, you can delete it using the Delete button in the prologue and try again, maybe with different params.

The default values for the `magma_generation_type` and `magma_generation_params` properties can be also configured for your application in `config.exs` like this

```elixir
config :magma,  
  default_generation: Magma.Generation.OpenAI
  
config :magma, Magma.Generation.OpenAI,  
  model: "gpt-4",  
  temperature: 0.6
```


The `default_generation` key sets the name of the `Magma.Generation` adapter which should be set on the `magma_generation_type` of new prompt documents and the configuration of this similarly the values for the `magma_generation_params` property.



# Context knowledge

##  Magma documents ![[Magma.Document#Description]]



# Artefacts

## Article

- Prompt: [[Prompt for Magma User Guide - Custom Prompts and Prompt Execution (article section)]]
- Final version: [[Magma User Guide - Custom Prompts and Prompt Execution (article section)]]

### Article prompt task

Your task is to write the section "Custom Prompts and Prompt Execution" of "Magma User Guide" in round about 2000 words.

![[ExDoc#Admonition blocks]]

![[Prompt snippets#Editorial notes]]

![[Prompt snippets#Cover all content]]
