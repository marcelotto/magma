---
magma_type: Artefact.Prompt
magma_artefact: Article
magma_concept: "[[Magma User Guide - Introduction to Magma]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-04 11:50:51
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

Final version: [[Magma User Guide - Introduction to Magma (article section)]]

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

# Prompt for Magma User Guide - Introduction to Magma (article section)

## System prompt

![[Magma.System.config#Persona|]]

![[UserGuide.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.System.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Text.Section.config#Context knowledge|]]

![[UserGuide.config#Context knowledge|]]

#### Outline of the 'Magma User Guide' content ![[Magma User Guide ToC#Magma User Guide ToC|]]

#### Magma artefact model ![[Magma artefact model#Description|]]

#### Transclusion resolution ![[Magma-Transclusion-Resolution#Compact Description|]]

![[Article.config#Context knowledge|]]

![[Magma User Guide - Introduction to Magma#Context knowledge|]]


## Request

![[Magma User Guide - Introduction to Magma#Article prompt task|]]

### Description of the intended content of the 'Introduction to Magma' section ![[Magma User Guide - Introduction to Magma#Description|]]
