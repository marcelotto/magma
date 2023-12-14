<!-- ExDoc doesn't support YAML frontmatter

---
magma_type: Artefact.Version
magma_artefact: Article
magma_concept: "[[Magma User Guide - Creating and Understanding Magma Artefacts]]"
magma_draft: "[[Generated Magma User Guide - Creating and Understanding Magma Artefacts (article section) (2023-10-31T02:26:01)]]"
created_at: 2023-10-31 02:26:17
tags: [magma-vault]
aliases: []
---

-->

# Creating and Understanding Magma Artefacts

In Magma, we have the ability to generate what we call *artefacts*. These are outputs or products of the Magma environment that are created using predefined workflows and prompts. The basis for this is the Magma artefact model, which we'll introduce in this section. 

Magma artefacts are things we want to generate. For example, these could be documentation artefacts like moduledocs for the API documentation, user guides, cheatsheets, a project website or README. There could also be code artefacts like test factories, properties etc., although these are not yet supported in the current version of Magma.

## Magma Artefact Model

The Magma artefact model is based on the concept of *Matters* and *Artefacts*. A Magma artefact is always about a specific subject matter, which is represented as an instance of a Magma matter type. Such a Magma matter instance is described in a concept document (`Magma.Concept`). The concept document also includes sections with prompts for the different kinds of artefacts for that matter. 

In the next step of the artefact generation process, the artefact prompt document (`Magma.Artefact.Prompt`) is composed. This special kind of Magma prompt document has the goal of generating a concrete version of an artefact in a Magma artefact version document (`Magma.Artefact.Version`). The content structure is determined by the artefact type and is filled with the relevant parts of the concept document and eventually some matter-specific parts, for example, the code of the module in the case of `Magma.Matter.Module` matter type.

After the execution of the artefact prompt, the best prompt result is selected as a draft for the artefact version document, which is finally edited and finalized by the user. 

Here's an illustrative sequence diagram showing the connection between these elements:

``` mermaid
sequenceDiagram
    participant Ma as Magma.Artefact
    participant Mm as Magma.Matter
    participant Mc as Magma.Concept
    participant Map as Magma.Artefact.Prompt
    participant Mpr as Magma.PromptResult
    participant Mav as Magma.Artefact.Version

    Ma->>Mm: is about
    Mm->>Mc: is described by
    Ma->>Map: determines structure of
    Mc->>Map: provides content for
    Map->>Mpr: is executed to generate
    Mpr->>Mav: is selected draft for
    Mav->>Ma: realizes
```


In summary, the general process of creating a Magma artefact involves the following steps:

1. **Write the concept**: Provide a description of the (subject) matter in the "Description" section of the concept document. Add necessary background knowledge in the "Context knowledge" section that helps to understand the description or generate artefacts about this matter. Customize the default prompt of the artefact to be created in the "Artefacts" section.
2. **Review the prompt** and refine the concept if necessary.
3. **Execute the prompt**. This can be done multiple times until you're satisfied with the result. Refine the concept and/or adapt the generation parameters in this iterative process.
4. **Select the best prompt result** as a draft for the final version.
5. **Edit and finalize** the final artefact version.

Let's see this workflow in action, by demonstrating the generation of the project README and a moduledoc.

## Generating a Project README

The first step is to write the concept of the project in the concept document. This document was already created during the vault initialization along with a prompt for the README artefact.

### The Concept Document

```markdown
---
magma_type: Concept
magma_matter_type: Project
magma_matter_name: Example
created_at: 2023-10-06 16:03:10
tags: [magma-vault]
aliases: [Example project, Example-project]
---
# Example project

## Description

<!--
What is the Example project about?
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

Generate a README for project 'Example' according to its description and the following information:  
  
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

The concept document has a YAML frontmatter which includes Obsidian properties (`created_at`, `tags`, `aliases`), the `magma_type` property specifying the Magma document type, and two new properties:

- `magma_matter_type`: Specifies the Magma matter type, in this case, `Project`.
- `magma_matter_name`: Specifies the name of the concrete matter, in this case, the name of the project. For matter types, where the matter name is the same as the document name, this property is not needed.

The main body of the concept includes:

#### a) Description of the Matter

The "Description" section of any concept document is crucial as it provides a description of its subject matter, in this case, the project, which will be transcluded as the central part in the request part of the prompt. This description can be written directly into this section or transcluded from other documents. 

> #### Info {: .info}
>
> As we saw in the last chapter, the project description is very important, as it is transcluded in the "Context knowledge" section of every custom prompt and every artefact prompt (except for those about the project itself, where it is transcluded more prominently since it's not just context knowledge in this case).

#### b) Context Knowledge

The "Context knowledge" section provides background information that helps to understand the matter and its description. For our project, for example, we could describe its ecosystem or some used technologies.

We encountered this section already in the introduction of [Custom prompts](Magma User Guide - Custom Prompts and Prompt Execution (article section).md). However, while in the case of a Custom prompt its content was specified directly in the prompt document, it is now specified in the concept document and transcluded in the prompts of all artefacts of this matter instance.

#### c) Artefacts

The "Artefacts" section includes subsections for all supported artefact types of the respective matter type. These subsections contain links to the respective artefact prompt and artefact version document, and a "Prompt task" section with the default prompt for the respective artefact type, which can be customized or extended for this particular instance here in the concept document. 

> #### Tip {: .tip}
> 
> If you want to customize the task prompt for an artefact type in general, you can do so in the "Task prompt" section of the config document of the respective artefact type in the `magma.config/artefacts` subdirectory of the vault. Note that this section is special because it is not transcluded, but interpreted as an EEx template that is evaluated when a concept document is created. The result of this evaluation is used as the content of the "Prompt task" section of the corresponding artefact type.

In the case of our project concept document, the only available artefact type in this first version of Magma is the README artefact. The system prompt for its generation is based on a template, which relies on some information, which should be provided in the given form in this section. If some fields do not apply for your project, you should write `n/a`.


### The Prompt Document

After filling the concept document, the artefact prompt document should be reviewed with the transcluded content. Let's look at the artefact prompt document that was generated during the vault initialization.

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

### Description of the 'Example' project ![[Project#Description|]]
```

You should notice its structure is very similar to the prompt shown in the previous page about "Custom prompts", but has some notable differences:

- In the YAML frontmatter, the properties `magma_artefact` and `magma_concept` have been added, which specify the artefact type and link to the concept document. 
- The **Generated results** now contains a dedicated link to the final artefact version document. 
- The **Actions** buttons now also have an update button, which you can use to regenerate the prompt. Although transcluded content is displayed automatically, it is sometimes necessary to regenerate the prompt (for example when source code, which is included for some artefact prompts, was modified, like for moduledocs), which can be done with this button or the `Mix.Tasks.Magma.Prompt.Update` Mix task.
- The "System prompt" section transcludes a section of the respective artefact type config document, which can be adapted to your specific needs. In the case of the README artefact type it contains a template for the README to be generated, which uses the fields of the form in the README artefact section in the concept document seen above.
- The "Context knowledge" section now includes a lot more transclusions from additional config documents, which allows you to compose the necessary knowledge more granular. After the "Context knowledge" section from the general `Magma.system.config` document that is always transcluded, we now see the following additional "Context knowledge" section transclusions:
	- from a config document for the matter type of the concept, in this case of the `Project` subject matter, the `Project.matter.config` document,
	- from a config document for the artefact type, in this case of a `Readme` artefact, the `Readme.artefact.config` document,
	- and finally, the "Context knowledge" section from the concept document above.

The artefact prompt can be executed in the same way as described in the "Custom Prompts and Prompt Execution" section of this guide. You may need to execute the prompt multiple times until you're satisfied with the result.

### The Prompt Result Documents

The prompt results now have an additional "Select as draft version" button, which you can use to select the best prompt result as a template for the artefact version. 

Alternatively, you can use the `Mix.Tasks.Magma.Artefact.SelectDraft` Mix task directly:

```sh
$ mix magma.artefact.select_draft "Name of prompt result"
```

> #### Warning {: .warning}
>
> If a README already exists and must be overwritten, you must use the Mix task to confirm the overwrite. If you want to use the button, you must manually remove the old version beforehand, as a confirmation is currently not supported in Obsidian.

### The Artefact Version Document

After selecting the best prompt result as a draft, a `README.md` file is created in the project's root directory and filled with the result. A symbolic link to this file is then created in the Magma vault where the artefact version is normally stored (`artefacts/final/project/README/README.md`). This allows the README to be opened and edited in Obsidian. 

As can be seen in this case of a README, artefact version documents are not always proper Magma documents, in the sense that they are properly typed with a `magma_type`, since this isn't possible, when the system consuming the artefact doesn't support YAML frontmatter.

With that, you can now complete the final version of the artefact. 


## Generating module documentation for the API documentation

The process of generating the ModuleDoc for API documentation is quite similar to that of generating a README. The related concept and artefact prompts are created either during the initialization of the vault or by a subsequent code sync (refer to the [Installation and setup](Magma User Guide - Installation and setup (article section).md) page for details). 

Although we're dealing with another matter type here, the concept documents are quite akin to those for the project which we saw in previous README example. The primary differences are:

- The `magma_matter_type` is `Module` instead of `Project`.
- The hints for the content to be written are tailored according to the `Module` matter type.
- The artefacts for the `Module` matter type are different. In the current version of Magma, only the `ModuleDoc` artefact type is available.

The primary goal of the `ModuleDoc` artefact is to generate the content for the `@moduledoc` string in the module's code. In fact, when the final artefact version is generated, you can use the `Magma` module as a replacement for the `@moduledoc` definition:

``` elixir
defmodule Some.Module do
  use Magma
  # will be replaced with a @moduledoc <content of ModuleDoc artefact version document>

  # some code   
end
```

> #### Warning {: .warning}
>
> If you decide to include your moduledocs with `use Magma`, be aware that if you're writing a library and your users should be able to use these docs on their machines, e.g. with the `h` helper in IEx you'll have to include the Magma documents with the final moduledocs in your package like this:
> 
> ```elixir
> defp package do  
>   [  
>     # ...
>     files:  ~w[lib priv mix.exs docs.magma/artefacts/final/modules/**/*.md]
>   ]  
> end  
> ```

However, the artefact prompt also asks for function docs for two reasons:

1.  It's challenging to get the language model to ignore the functions and focus solely on the `@moduledoc`. It tends to describe the functions present in the shown implementation.
2.  Even though Magma doesn't currently offer a similar integration for function docs as it does for `@moduledoc`, they are useful as copy-paste templates.

Here is a detailed look at the prompt for the `ModuleDoc` artefact (without the YAML frontmatter and prologue with the document controls, which are similar to the README prompt above):

```markdown
# Prompt for ModuleDoc of Some.Example

## System prompt

![[Magma.system.config#Persona|]]

![[ModuleDoc.artefact.config#System prompt|]]

### Context knowledge

The following sections contain background knowledge you need to be aware of, but which should NOT necessarily be covered in your response as it is documented elsewhere. Only mention absolutely necessary facts from it. Use a reference to the source if necessary.

![[Magma.system.config#Context knowledge|]]

#### Description of the Magma project ![[Project#Description|]]

![[Module.matter.config#Context knowledge|]]

#### Peripherally relevant modules

##### `Some` ![[Some#Description|]]

##### `Some.Example.Nested` ![[Some.Example.Nested#Description|]]

![[ModuleDoc.artefact.config#Context knowledge|]]

![[Some.Example#Context knowledge|]]


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

Besides the project description, the "Context knowledge" section now transcludes the descriptions of all modules beneath the module to be documented  in a subsection "Peripherally relevant modules". For example, for a module `A.B.C`, the descriptions of the modules `A` and `A.B` are transcluded here. Also, all direct submodules are transcluded, i.e. in this case all modules `Some.Example.*`. If you prefer to transclude module descriptions on your own and want to circumvent possible duplicate transclusions, these automatic module context transclusions can be disabled via the `auto_module_context` property in the `Module.matter.config` document.

As can be seen in this artefact prompt, the "Request" section also includes the actual source code of the module to be documented. Use the "Update" button from the **Actions** in the prologue, to update the prompt after modifications of the code.

The process of executing the artefact prompt and choosing the final artefact is similar to the README artefact. However, that the artefact version can now be kept in a proper artefact version document (with respective YAML frontmatter) at the place where it belongs (in this case `artefacts/final/modules/Some/Module/ModuleDoc of Some.Module.md`) and without the need for a symbolic link.
