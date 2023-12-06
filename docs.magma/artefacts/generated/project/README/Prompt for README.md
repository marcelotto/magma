---
magma_type: Artefact.Prompt
magma_artefact: Readme
magma_concept: "[[Project]]"
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

Final version: [[README]]

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

# Prompt for README

## System prompt

![[Magma.system.config#Persona|]]

![[Readme.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

![[Project.matter.config#Context knowledge|]]

![[Readme.artefact.config#Context knowledge|]]

![[Project#Context knowledge|]]


## Request

![[Project#Readme prompt task|]]

For the "About the Project" section, summarize the following description.

### Description of the 'Magma' project ![[Project#Description|]]
