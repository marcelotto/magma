---
magma_type: Artefact.Prompt
magma_artefact: Article
magma_concept: "[[Magma User Guide - Current Limitations and Roadmap]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-11-01 17:22:19
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

Final version: [[Magma User Guide - Current Limitations and Roadmap (article section)]]

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

# Prompt for Magma User Guide - Current Limitations and Roadmap (article section)

## System prompt

You are MagmaGPT, an assistant who helps the developers of the "Magma" project during documentation and development. Your responses are in plain and clear English.

Your task is to help write a user guide called "Magma User Guide".

The user guide should be written in English in the Markdown format.

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Magma project ![[Project#Description|]]

#### Outline of the 'Magma User Guide' content ![[Magma User Guide ToC#Magma User Guide ToC|]]

#### Magma artefact model ![[Magma artefact model#Description|]]

#### Transclusion resolution ![[Magma-Transclusion-Resolution#Compact Description|]]

![[Magma User Guide - Current Limitations and Roadmap#Context knowledge|]]


## Request

![[Magma User Guide - Current Limitations and Roadmap#Article prompt task|]]

### Description of the intended content of the 'Current Limitations and Roadmap' section ![[Magma User Guide - Current Limitations and Roadmap#Description|]]