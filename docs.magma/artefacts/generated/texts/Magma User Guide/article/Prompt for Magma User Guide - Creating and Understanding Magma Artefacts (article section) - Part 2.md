---
magma_type: Artefact.Prompt
magma_artefact: Article
magma_concept: "[[Magma User Guide - Creating and Understanding Magma Artefacts]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.7}
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

Your task is to write the Part 2 of 3 of the section "Creating and Understanding Magma Artefacts" of "Magma User Guide", which should consist of a step-by-step-guide for generating the README. (Part 1 of this section will introduce the Magma artefact model and part 3 will consist of the step-by-step-guide for generating a moduledoc. Don't mention the different parts. They should be concatenated latter into one section.)

EVERYTHING from the following "Generating a project README" section should be present in the generated result. So, your task essentially is to reorganize the content should be structured around the following general Magma artefact creation workflow:

![[Magma artefact model#General Magma artefact creation workflow]]

![[ExDoc#Admonition blocks]]

IMPORTANT: DO NOT LEAVE ANYTHING OUT of the following "Generating a project README" section! Everything should be in the generated result somewhere

### Generating a project README

During the vault initialization the concept document for the project and a prompt for the README artefact was already created. Let's look at the concept document first:

```markdown
[...]
```


As usual the document starts with the YAML frontmatter. Besides the usual Obsidian properties `created_at`, `tags` and `aliases` and the `magma_type` property specifying the Magma document type, we already saw in the last section, we can see two new properties here:

- `magma_matter_type`: specifies the Magma matter type, in this case we have the `Project` matter type
- `magma_matter_name`: This property is used in cases where the matter name is different than the name of the concept document, to specify the name of the concrete matter, in this case the name of the project. For matter types, where the matter name equals the document name (which often is, like for example in the case of the `Module` we'll see in the next section), this property is not needed/used.

Then follows the main body of the concept, which already includes some comments with hints on what is expected to be written in the respective sections (Remember: comments are removed, when transclusions are resolved, so you're free keep them when you want as they want appear in the rendered prompts.)

- The most important part of any concept document is the "Description" section, which should include a description of its subject matter, so in this case the project.
	- As we noted already in the Custom prompt section of this guide, this project description is very important, as it will be transcluded in the "Context knowledge" section of every custom prompt and every artefact prompt (except for the artefact prompts of artefacts about the project itself, where this description becomes part more prominent request part of the prompt).
	- You either write the description directly into this section or transclude its content from other documents are a combination of both.
- The "Context knowledge" was also already introduced in the Custom prompt section of this guide. However, while in the case of a Custom prompt its content was specified directly in the prompt document, it is now specified in the concept document and transcluded in the prompts of all artefacts of this subject matter.
- Below the "Artefacts" section of a Concept document are subsections for all supported artefact types of the respective matter type (`magma_matter_type`), containing the following:  
	- Links to the respective artefact prompt and artefact version document.
	- A "prompt task" section containing the text for the prompt to generate this artefact, populated with a default text for this artefact type, which can be customized or extended. This text is transcluded in the request part of the prompt (Remember: the artefact prompt should not contain any user contributed parts directly and should be able to be regenerated at any time). 
		- In the case of our project concept document, the only available artefact type in this first version of Magma is the README artefact. The system prompt for its generation is based on a template, which relies on some information, which should be provided the given form.

Let's look at the artefact prompt document:

```markdown
[...]

```

As you can see this is very similar to the prompt shown in the "Custom prompt" chapter, so here only to the differences:

- In the YAML frontmatter, the properties `magma_artefact` and `magma_concept` have been added, which specify the artefact type and link to the concept document.
- **Generated results** now contains a dedicated link to the final artefact version document (which of course still points to nowhere as long as it has not yet been generated and selected).
- The **Actions** buttons now also have an update button. Although transcluded content is displayed automatically, it is sometimes necessary to regenerate the prompt (for example when source code which is included for some artefact prompts was modified, like for moduledocs), which can be done with this button or the mix task `magma.prompt.gen`.

The main part of the artefact prompt is also structurally identical to the custom prompt. Apart from the system prompt, which is prefilled with an artefact-type-specific static text, you can see how the different parts of the concept document are transcluded.

So, with that, it should be clear how to fill out the concept document.

When finished, the artefact prompt can then be executed in the same way as described in the "Custom Prompts and Prompt Execution" section of this guide. The prompt result, however, now has an additional "Select as draft version" button, with which the best prompt result is selected as a template for the artefact version. Normally, this selection creates an artefact version document and fills it with the contents of the selected prompt result. In the case of a README that should be outside the vault in projects root directory and for which YAML frontmatter is also unwanted, this is what happens when selecting a prompt result with this button or the Mix task `magma.artefact.select_draft`:

- A file `README.md` is created in the projects root directory and filled with the result. If this already exists and must be overwritten, the Mix task must be used to confirm the overwrite. If the button is to be used, the old version must be removed manually beforehand, since a confirmation is currently not supported in Obsidian.
- Subsequently, a symbolic link to this file is created at the location in the Magma vault where the artefact version is normally stored (in this case `artefacts/final/project/README/README.md`), so that the README can also be opened and edited in Obsidian.
- With that, the completion of the final version can be done by the user.

