---
magma_type: Concept
magma_matter_type: Text.Section
magma_section_of: "[[Magma User Guide]]"
created_at: 2023-10-20 09:53:31
tags: [magma-vault]
aliases: []
---
# Creating and Understanding Magma Artefacts

## TODO

- add final artefact version of [[Magma User Guide - Custom Prompts and Prompt Execution]] when done
- Strategies for shorting
	- shorten prompt documents (controls and system prompt) temporarily and add them back in the final version
	- separate generation of different parts (general model introduction and step-by-step guides)

## Description

Abstract: This section explains the concepts of 'Matter' and 'Artefacts' in Magma. It describes what an Artefact is and how it is generated with the the different kinds of Magma documents. It also demonstrates how Magma can be used to generate simple artefacts like a project README or the API documentation for Elixir with a step-by-step guide.

In contrast to the custom prompts introduced in the previous section, Magma offers the possibility of generating so-called *artefacts*, with predefined workflows and  prompts. The basis for this is the Magma artefact model, which should be introduced in this section. The following two sections of the guide then demonstrate how simple artefacts (which consist of exactly one `Artefact.Version` document) and complex text artefacts (which consist of several `Artefact.Version` documents which are finally assembled) can be created with this.  

### Magma artefact model 

The following technical description should serve as a basis for generated introduction to the model and be prepared accordingly. Here, of course, natural language identifiers should be used instead of module names (which should not appear in this section!). Please also include the provided diagram to illustrate the model. Feel free to add more explanations, examples or illustrations to make the model more understandable.

![[Magma artefact model#Description|]]

![[Magma artefact model#Sequence diagram]]

<!--
Ommitted for token limit reasons:

### Magma matter ![[Magma.Matter#Description]]

### Magma artefact ![[Magma.Artefact#Description]]

### Magma concept documents ![[Magma.Concept#Description]]

### Magma artefact prompt documents ![[Magma.Artefact.Prompt#Description]]

### Magma artefact version documents ![[Magma.Artefact.Version#Description]]
-->

### Generating a project README

During the vault initialization the concept document for the project and a prompt for the README artefact was already created. Let's look at the concept document first:

```markdown
---
magma_type: Concept
magma_matter_type: Project
magma_matter_name: Name of your project
created_at: 2023-10-06 16:03:10
tags: [magma-vault]
aliases: [Magma project, Magma-project]
---
# Magma project

## Description

<!--
What is the Magma project about?
-->


# Context knowledge

<!--
This section should include background knowledge needed for the model to create a proper response, i.e. information it does not know either because of the knowledge cut-off date or unpublished knowledge.

Write it down right here in a subsection or use a transclusion. If applicable, specify source information that the model can use to generate a reference in the response.
-->




# Artefacts

## README

- Prompt: [[Prompt for project README]]
- Final version: [[README]]

### Readme prompt task

Generate a README for project 'Name of your project' according to its description and the following information:  
  
Hex package name: app_name
Repo URL: https://github.com/github_username/repo_name  
Documentation URL: https://hexdocs.pm/app_name/
Homepage URL:  
Demo URL:  
Logo path: logo.jpg  
Screenshot path:  
License: MIT License  
Contact: Your Name - [@twitter_handle](https://twitter.com/twitter_handle) - your@email.com  
Acknowledgments:  
  
("n/a" means not applicable and should result in a removal of the respective parts)

```

As usual the document starts with the YAML frontmatter:

- `magma_type`:  specifying the Magma document type, we can see that we have a concept document here
- `magma_matter_type`: specifies the Magma matter type, in this case we have the `Project` matter type
- `magma_matter_name`: this property is used in cases where the matter name is different than the name the concept document (which often is, like for example in the case of the `Module` we'll see in the next section), to specify the name of the concrete matter, in this case the name of the project
- the `created_at`, `tags` and `aliases` properties are the usual Obsidian properties
	- Note, that the default tag `magma-vault` was added as configured in the "Installation and setup" section.
	- Also, some aliases are defined by default for the project concept document.

Then follows the main body of the concept, which already includes some comments with hints on what is expected to be written in the respective sections (Remember: comments are removed, when transclusions are resolved, so you're free keep them when you want as they want appear in the rendered prompts.)

- The most important part of any concept document is the "Description" section, which should include a description its subject matter, so in this case the project.
	- As we noted already in the Custom prompt section of this guide, this project description is very important, as it will be transcluded in the "Context knowledge" section of every custom prompt and every artefact prompt (except for the artefact prompts of artefacts about the project itself, where this description becomes part more prominent request part of the prompt).
	- You either write the description directly into this section or transclude its content from other documents are a combination of both.
- The "Context knowledge" was also already introduced in the Custom prompt section of this guide. However, while in the case of a Custom prompt its content was specified directly in the prompt document, it is now specified in the concept document and transcluded in the prompts of all artefacts of this subject matter.
- Below the "Artefacts" section of a Concept document are subsections for all supported artefact types of the respective matter type (`magma_matter_type`), containing the following:  
	- Links to the respective artefact prompt and artefact version document.
	- A "prompt task" section containing the text for the prompt to generate this artefact, populated with a default text for this artefact type, which can be customized or extended. This text is transcluded in the request part of the prompt (Remember: the artefact prompt should not contain any user contributed parts directly and should be able to be regenerated at any time). 
		- In the case of our project concept document, the only available artefact type in this first version of Magma is the README artefact. The system prompt for its generation is based on a template, which relies on some information, which should be provided the given form.

Let's look at the artefact prompt document:

```markdown
---
magma_type: Artefact.Prompt
magma_artefact: Readme
magma_concept: "[[Project]]"
magma_generation_type: OpenAI
magma_generation_params: {"model":"gpt-4","temperature":0.6}
created_at: 2023-10-24 16:05:35
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

Final version: [[README]]

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
``button
name Update
type command
action Shell commands: Execute: magma.prompt.update
color default
``

# Prompt for README

## System prompt

You are MagmaGPT, an assistant who helps the developers of the "Name of your project" project during documentation and development. Your responses are in plain and clear English.

Your task is to generate a project README using the following template, replacing the content between {{ ... }} accordingly:

[... the README template is omitted here ...]


### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Project#Context knowledge]]


## Request

![[Project#Readme prompt task|]]

### Description of the 'Name of your project' project ![[Project#Description|]]
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

### Generating module documentation for the API documentation

The generation of the moduledoc of a module for the API documentation looks very similar. Here, too, the corresponding concept and artefact prompts were already created during the initialization of the vault (or by a subsequent code sync; see "Installation and Setup" section).

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
# Prompt for ModuleDoc of Some.Example

## System prompt

You are MagmaGPT, an assistant who helps the developers of the "Name of your project" project during documentation and development. Your responses are in plain and clear English.

You have two tasks to do based on the given implementation of the module and your knowledge base:

1. generate the content of the `@doc` strings of the public functions
2. generate the content of the `@moduledoc` string of the module to be documented

Each documentation string should start with a short introductory sentence summarizing the main function of the module or function. Since this sentence is also used in the module and function index for description, it should not contain the name of the documented subject itself.

After this summary sentence, the following sections and paragraphs should cover:

- What's the purpose of this module/function?
- For moduledocs: What are the main function(s) of this module?
- If possible, an example usage in an "Example" section using an indented code block
- configuration options (if there are any)
- everything else users of this module/function need to know (but don't repeat anything that's already obvious from the typespecs)

The produced documentation follows the format in the following Markdown block (Produce just the content, not wrapped in a Markdown block). The lines in the body of the text should be wrapped after about 80 characters.

``markdown
## Function docs

### `function/1`

Summary sentence

Body

## Moduledoc

Summary sentence

Body
``

<!--
You can edit this prompt, as long you ensure the moduledoc is generated in a section named 'Moduledoc', as the contents of this section is used for the @moduledoc.
-->

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

#### Description of the Magma project ![[Project#Description|]]

#### Peripherally relevant modules

##### `Some` ![[Some#Description|]]


## Request

![[Some.Example#ModuleDoc prompt task|]]

### Description of the module `Some.Example` ![[Some.Example#Description|]]

### Module code

This is the code of the module to be documented. Ignore commented out code.

``elixir
defmodule Some.Module do
  use Magma

  # some code	
end
``
```

Here are some points to be noted compared to our previous example of the README prompt:

- "Context knowledge" section:
	- As in all prompts (except those for the project itself), the project description is transcluded here.
	- The descriptions of all modules below the module to be documented are automatically included in a subsection "Peripherally relevant modules" by transclusion, i.e. for a module `A.B.C` the descriptions of the modules `A` and `A.B` are included here.
- "Request" section: 
	- Here the actual source code of the module to be documented is included. Use the "Update" button from the **Actions** in the prologue, to update the prompt after modifications of the code.

The execution of the artefact prompt and the selection of the final artefact work is similar as in our README artefact example above, except that the artefact version can now be kept in a proper artefact version document (with respective YAML frontmatter) at the place where it belongs (in this case `artefacts/final/modules/Some/Module/ModuleDoc of Some.Module.md`) without the need for a symbolic link.

# Context knowledge



# Artefacts

## Article

- Prompt: [[Prompt for Magma User Guide - Creating and Understanding Magma Artefacts (article section)]]
- Final version: [[Magma User Guide - Creating and Understanding Magma Artefacts (article section)]]

### Article prompt task

Your task is to write the section "Creating and Understanding Magma Artefacts" of "Magma User Guide".

![[ExDoc#Admonition blocks]]

![[Prompt snippets#Editorial notes]]

![[Prompt snippets#Cover all content]]
