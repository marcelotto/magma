---
magma_type: Artefact.Prompt
magma_artefact: Article
magma_concept: "[[Magma User Guide - Creating and Understanding Magma Artefacts]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.5}
created_at: 2023-10-31 02:18:27
tags: [magma-vault]
aliases: []
---

**Generated results**

```dataview
TABLE
	tags AS Tags,
	magma_generation_type AS Generator,
	magma_generation_params AS Params
WHERE magma_prompt = [[]]
SORT created_at DESC
```

Final version: [[Magma User Guide - Creating and Understanding Magma Artefacts (article section)]]

**Actions**

```button
name Execute
type command
action Shell commands: Execute: magma.prompt.exec
color blue
```
```button
name Execute manually
type command
action Shell commands: Execute: magma.prompt.exec-manual
color blue
```
```button
name Copy to clipboard
type command
action Shell commands: Execute: magma.prompt.copy
color default
```
```button
name Update
type command
action Shell commands: Execute: magma.prompt.update
color default
```

# Prompt for Magma User Guide - Creating and Understanding Magma Artefacts (article section)

## System prompt

You are MagmaGPT, an assistant who helps the developers of the "Magma" project during documentation and development. Your responses are in plain and clear English.

Your task is to help write a user guide called "Magma User Guide".

The user guide should be written in English in the Markdown format.

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Magma project ![[Project#Description|]]
#### Magma artefact model ![[Magma artefact model#Description]]

#### Transclusion resolution ![[Magma-Transclusion-Resolution#Compact Description|]]


## Request

Your task is to write the Part 3 of 3 of the section "Creating and Understanding Magma Artefacts" of "Magma User Guide", which should consist of a step-by-step-guide for generating the ModuleDoc of module. (Part 1 of this section will introduce the Magma artefact model and part 2 will consist of the step-by-step-guide for generating a README. Don't mention the different parts. They should be concatenated latter into one section.)

EVERYTHING from the following "Generating module documentation for the API documentation" section should be present in the generated result. So, your task essentially is to make the text more coherent and fluid. We don't need no further subsections.

![[ExDoc#Admonition blocks]]


### Generating module documentation for the API documentation

The generation of the moduledoc of a module for the API documentation looks very similar as that for the README. Here, too, the corresponding concept and artefact prompts were already created during the initialization of the vault (or by a subsequent code sync; see "Installation and Setup" section).

The concept documents look very similar, just 

- a different `magma_matter_type` (`Module`)
- different hints what to write, according to the different subject matter type
- and the other available artefacts of the `Module` matter type, again we have just one artefact type available for now in this first version of Magma: the `ModuleDoc` artefact type with a respective prompt task

As the name suggests the main goal of the ModuleDoc artefact is the generation of the content of the `@moduledoc` string. In fact, when the final artefact version is generated you can write `use Magma` as a replacement for the `@moduledoc` definition:

```elixir
defmodule Some.Module do
  use Magma
  # will be replaced with a @moduledoc <content of ModuleDoc artefact version document>

  # some code	
end
```

The artefact prompt, however, also asks for function docs for two reasons:

1. It's actually hard to get the LLM to ignore the function and focus on the moduledoc. It wants to describe the functions it is shown in the implementation somewhere.
2. Although a similar integration of the docs as that of the moduledocs via `use Magma` is not offered for functions (and possibly will not be in the future, since one will certainly not want to separate them from the code), they are still useful as copy-paste templates. (In fact, many users will probably also want to use the moduledocs only as copy-paste templates for these very reasons).

Let's look at the prompt for the ModuleDoc artefact in detail (the main body only, since the frontmatter and prologue are very similar to what saw above):

```markdown
[...]
```

Here are some points to be noted compared to our previous example of the README prompt:

- "Context knowledge" section:
	- As in all prompts (except those for the project itself), the project description is transcluded here.
	- The descriptions of all modules below the module to be documented are automatically included in a subsection "Peripherally relevant modules" by transclusion, i.e. for a module `A.B.C` the descriptions of the modules `A` and `A.B` are included here.
- "Request" section: 
	- Here the actual source code of the module to be documented is included. Use the "Update" button from the **Actions** in the prologue, to update the prompt after modifications of the code.

The execution of the artefact prompt and the selection of the final artefact work is similar as in our README artefact example above, except that the artefact version can now be kept in a proper artefact version document (with respective YAML frontmatter) at the place where it belongs (in this case `artefacts/final/modules/Some/Module/ModuleDoc of Some.Module.md`) without the need for a symbolic link.

