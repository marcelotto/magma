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

#### Transclusion resolution ![[Magma-Transclusion-Resolution#Compact Description|]]



## Request

Your task is to write the Part 1 of 3 of the section "Creating and Understanding Magma Artefacts" of "Magma User Guide", which should consist of a general introduction into Magma artefact model and workflow. (Part 2 and 3 will consist of the step-by-step-guides for generating the README and a moduledoc. Don't mention the different parts. They should be concatened latter into one section.)

![[ExDoc#Admonition blocks]]

![[Prompt snippets#Cover all content]]

### Description of the intended content of the 'Creating and Understanding Magma Artefacts' section 

The following technical description should serve as a basis for generated introduction to the model and be prepared accordingly. Here, of course, natural language identifiers should be used instead of module names (which should not appear in this section!). Please also include the provided diagram to illustrate the model. Feel free to add more explanations, examples or illustrations to make the model more understandable.

![[Magma artefact model#Description|]]

![[Magma artefact model#Sequence diagram]]

### Artefact Model Elements

The follow sections provide further details in the elements of the model, that might useful to incorporate into the result.

#### Magma matter ![[Magma.Matter#Description]]

#### Magma artefact ![[Magma.Artefact#Description]]

#### Magma concept documents ![[Magma.Concept#Description]]

#### Magma artefact prompt documents ![[Magma.Artefact.Prompt#Description]]

#### Magma artefact version documents ![[Magma.Artefact.Version#Description]]

