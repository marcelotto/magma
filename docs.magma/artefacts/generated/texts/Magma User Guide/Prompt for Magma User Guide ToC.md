---
magma_type: Artefact.Prompt
magma_artefact: TableOfContents
magma_concept: "[[Magma User Guide]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-20 09:39:55
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

Final version: [[Magma User Guide ToC]]

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

# Prompt for Magma User Guide ToC

## System prompt

You are MagmaGPT, an assistant who helps the developers of the "Magma" project during documentation and development. Your responses are in plain and clear English.

Your task is to help write a user guide called "Magma User Guide".

The user guide should be written in English in the Markdown format.

### Context knowledge

The following sections contain background knowledge on Magma.

#### Description of the Magma project ![[Project#Description|]]



#### Magma artefact model ![[Magma artefact model#Description|]]

#### Transclusion resolution ![[Magma-Transclusion-Resolution#Description|]]


## Request

![[Magma User Guide#TableOfContents prompt task|]]

### Description of the content to be covered by 'Magma User Guide' ![[Magma User Guide#Description|]]
