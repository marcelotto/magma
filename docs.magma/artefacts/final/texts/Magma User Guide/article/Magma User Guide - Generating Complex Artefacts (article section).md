<!-- ExDoc doesn't support YAML frontmatter

---
magma_type: Artefact.Version
magma_artefact: Article
magma_concept: "[[Magma User Guide - Generating Complex Artefacts]]"
magma_draft: "[[Generated Magma User Guide - Generating Complex Artefacts (article section) (2023-11-01T13:21:49)]]"
created_at: 2023-11-01 13:29:41
tags: [magma-vault]
aliases: []
---

-->

# Generating Complex Artefacts

This section shows how Magma can be used to generate longer texts, such as user guides. It provides a detailed guide on how to use Magma for generating such complex artefacts composed of other artefacts.

Due to the token limits of an LLM, generating lengthy texts can be challenging. Instead of generating complete texts all at once, Magma generates these texts section by section. The text generation process is modelled as follows:

- Texts (`Magma.Matter.Text`) are a complex Magma matter type composed of various sections (`Magma.Matter.Text.Section`), which is also a Magma matter type.
- The overall scope of the text is described in the concept document, which is used to generate a Table of Contents artefact. This artefact guides the generation of initial concept documents for the sections of the text.
- The content of each section is described in its concept document. From these descriptions, parts of various artefacts such as an article, a presentation slide deck, or a screencast script can be generated. Currently, however, only the `Magma.Artefacts.Article` artefact type is implemented in Magma.
- Finally, the final artefact version of the whole artefact version of a text is assembled from the artefact versions of the sections.

This might sound rather complex, but is in practice quite straightforward. Let's walk through the process of creating an article using Magma to see this in action.

## Creating Initial Documents

You can create the initial documents for a new text with the `Mix.Tasks.Magma.Text.New` Mix task. The first argument is the title of your text, followed by an optional text type:

```sh
$ mix magma.text.new "Example User Guide" UserGuide
```

The text types determine the details of the system prompt of the artefact prompts. If no text type is provided, a minimal generic system prompt is used. Currently, there is only one text type predefined in this early stage of development, the `UserGuide` type. 

> #### Tip {: .tip}
> 
>With the `Mix.Tasks.Magma.Text.Type.New` Mix task, you can easily create your own text types. The given text type name must be a valid Elixir module name.
> 
> ```sh
> $ mix magma.text.type.new Book
> ```
> 
> This will create a new text type config document in the `magma.config/text_types` subdirectory of your vault, where you can define the system prompt and context knowledge for it. (If you created a generally useful text type, it would be nice to share it by opening a PR to add it to Magma. 🙏)

The following is an example of what the concept document looks like:

```markdown
---
magma_type: Concept
magma_matter_type: Text
magma_matter_text_type: UserGuide
created_at: 2023-10-20 08:49:14
tags: [magma-vault]
aliases: []
---
# Example User Guide

## Description

<!--  
What should "Example User Guide" cover?  
-->


# Context knowledge

<!--  
This section should include background knowledge needed for the model to create a proper response, i.e. information it does not know either because of the knowledge cut-off date or unpublished knowledge.  
  
Write it down right here in a subsection or use a transclusion. If applicable, specify source information that the model can use to generate a reference in the response.
-->


# Sections

<!--  
Don't remove or edit this section! The results of the generated table of contents will be copied to this place.  
-->


# Artefact previews

-   [[Example User Guide (article) Preview]]


# Artefacts

## TableOfContents

-   Prompt: [[Prompt for Example User Guide ToC]]
-   Final version: [[Example User Guide ToC]]

### TableOfContents prompt task

Your task is to write an outline of "Example User Guide".

Please provide the outline in the following format:

``markdown
## Title of the first section

Abstract: Abstract of the introduction.

## Title of the next section

Abstract: Abstract of the next section.

## Title of the another section

Abstract: Abstract of the another section.
``

<!--
Please don't change the general structure of this outline format. The section generator relies on an outline with sections.
-->
```

As you can see, there is a description section here as in every concept document. In this section, all content that should be included in the text should be roughly outlined. A detailed context knowledge base is also essential in this case.

## Generating a Table of Content

In the "Artefacts" section, there is only a subsection for the generation of a table of contents (`Magma.Artefacts.TableOfContents` artefact type), which plays an important role in the following steps. From the generated table of contents artefact, the concept and artefact prompt documents of the individual sections are generated later. For this, it is important that the sections to be generated are specified in the produced artefact version of the table of contents as Markdown sections, which is pointed out by the comment at the end. However, as far as content in these sections is concerned, there are no specific requirements. The content generated by the LLM in these sections is used as the first content of the description of the concept of the respective section. Therefore, the generation of an abstract is requested here. However, the template can also be adapted in this respect if something different or additional is to be generated here.

The artefact prompt of the table of contents, its execution, and the creation of the artefact version are similar to the steps described in the previous chapters for generating other artefacts. The only notable difference for the prompts of artefacts about texts is that the transcluded system prompt is not coming from an artefact config document, but a config document for the text type, in this case the `UserGuide.text_type.config` document. This config document also defines a "Context knowledge" section which gets transcluded in the "Context knowledge" section of the prompt.

## Assembling Sections

Once the artefact version of the table of contents is generated, you can assemble the sections using the "Assemble sections" button or the `Mix.Tasks.Magma.Text.Assemble` Mix task:

```sh
mix magma.text.assemble "Example User Guide ToC"
```

This task performs the following actions:

-   It creates a concept document and an artefact prompt for each section of the article.
-   It transcludes the descriptions of the sections in the "Sections" section of the concept document, providing an overview of the entire article.
-   It creates a preview document for each artefact type of the text (currently only article). This document transcludes the artefact versions of all sections, allowing you to see a complete representation of the finished article at all times. It also serves as a basis for the final generation of the complete text by resolving the transclusions, which can be done using the "Finalize" button in the preview document or the `Mix.Tasks.Magma.Text.Finalize`:

    ```sh
    mix magma.text.finalize "Example User Guide (article) Preview"
    ```

## Example

Let's illustrate this with another example. Suppose we want to create an article titled "Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs". Let's say after having the described what the text should be about in the concept, we came up with the following artefact version of the table of contents:

```markdown
---
magma_type: Artefact.Version
magma_artefact: TableOfContents
magma_concept: "[[Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs]]"
magma_draft: "[[Generated Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs ToC (2023-10-25T22:31:55)]]"
created_at: 2023-10-25 22:31:33
tags: [magma-vault]
aliases: []
---

``button
name Assemble sections
type command
action Shell commands: Execute: magma.text.assemble
color blue
``


# Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs TOC

## The Hurdles of Handling Voluminous Text

Abstract: Delving into the limitations of chat dialogs when managing extensive textual data. Issues such as scrolling challenges, lack of effective text segmentation, and limited editing capabilities come to the fore.

## Contextual Challenges and Fragmented Conversations

Abstract: Highlighting the issues of maintaining coherence and context in lengthy, intricate discussions within chat interfaces. This includes the frequent need for users to backtrack or reintroduce topics, leading to disjointed conversations.

## Rethinking the Interface

Abstract: Proposing alternative interfaces and modifications to address the identified challenges. From multi-pane designs to advanced organizational tools, a look into potential ways to enhance the experience of crafting complex texts with LLMs.
```

If we hit the "Assemble sections" button, the "Section" section of our text concept document will be filled with this:

```markdown
# Sections

## [[Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs - The Hurdles of Handling Voluminous Text|The Hurdles of Handling Voluminous Text]] ![[Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs - The Hurdles of Handling Voluminous Text#Description|]]

## [[Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs - Contextual Challenges and Fragmented Conversations|Contextual Challenges and Fragmented Conversations]] ![[Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs - Contextual Challenges and Fragmented Conversations#Description|]]

## [[Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs - Rethinking the Interface|Rethinking the Interface]] ![[Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs - Rethinking the Interface#Description|]]
```

This looks quite overwhelming in this raw form, but it will look much cleaner when rendered in Obsidian: while the section titles link to the respective section concept documents, the content of the user written descriptions is transcluded.

The preview document looks very similar but transcludes the artefact versions of the sections instead.

A generated concept document for a section would look like this:

```markdown
---
magma_type: Concept
magma_matter_type: Text.Section
magma_section_of: "[[Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs]]"
created_at: 2023-10-25 22:42:35
tags: [magma-vault]
aliases: []
---
# Rethinking the Interface

## Description

Abstract: Proposing alternative interfaces and modifications to address the identified challenges. From multi-pane designs to advanced organizational tools, a look into potential ways to enhance the experience of crafting complex texts with LLMs.


# Context knowledge

<!--
This section should include background knowledge needed for the model to create a proper response, i.e. information it does not know either because of the knowledge cut-off date or unpublished knowledge.

Write it down right here in a subsection or use a transclusion. If applicable, specify source information that the model can use to generate a reference in the response.
-->


# Artefacts

## Article

- Prompt: [[Prompt for Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs - Rethinking the Interface (article section)]]
- Final version: [[Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs - Rethinking the Interface (article section)]]

### Article prompt task

Your task is to write the section "Rethinking the Interface" of "Chat Dialogues and Complexity - The Mismatch in Crafting Elaborate Texts with LLMs".

```

The individual artefact versions of the sections can be generated in the usual way:

1.  Write the concepts of each section, i.e., fill the "Description" section and compile the "Context knowledge". (Note: The content of the "Context knowledge" section of the concept of the whole text is transcluded in the respective artefact prompt of the section, i.e., only the section-specific "Context knowledge" of the respective section must be specified.)
2.  Execute the prompt to generate different prompt results.
3.  Select the best prompt result as the basis for the artefact version.
4.  Edit the final version, which should now also be reviewed in the preview in the overall context.

This process ensures that you can generate complex artefacts in a structured and manageable way with Magma.
