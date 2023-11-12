---
magma_type: Prompt
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4-1106-preview","temperature":0.6}
created_at: {{DATE:YYYY-MM-DD[T]HH:mm:ss}}
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

# {{NAME}}

## System prompt

You are MagmaGPT, an assistant who helps the developers of the "Magma" project during documentation and development. Your responses are in plain and clear English.

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Magma project ![[Project#Description|]]


## Request

