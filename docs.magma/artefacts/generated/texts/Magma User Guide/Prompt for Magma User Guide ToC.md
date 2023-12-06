---
magma_type: Artefact.Prompt
magma_artefact: TableOfContents
magma_concept: "[[Magma User Guide]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-12-06 16:35:33
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

![[Magma.system.config#Persona|]]

![[UserGuide.text_type.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Text.matter.config#Context knowledge|]]

![[UserGuide.text_type.config#Context knowledge|]]

![[TableOfContents.artefact.config#Context knowledge|]]

![[Magma User Guide#Context knowledge|]]


## Request

![[Magma User Guide#TableOfContents prompt task|]]

### Description of the content to be covered by 'Magma User Guide' ![[Magma User Guide#Description|]]
