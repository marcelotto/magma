<!-- ExDoc doesn't support YAML frontmatter

---
magma_type: Artefact.Version
magma_artefact: Article
magma_concept: "[[Magma User Guide - Introduction to Magma]]"
magma_draft: "[[Generated Magma User Guide - Introduction to Magma (article section) (2023-11-01T03:46:14)]]"
created_at: 2023-11-01 16:09:41
tags: [magma-vault]
aliases: []
---

-->

# Introduction

Magma is an environment designed to support developers in writing and executing complex prompts. Although it's primarily targeted at Elixir developers, the system's core concept of prompt composition via transclusions makes it a powerful tool even outside this context. Magma also provides a solution when you need to generate longer and more complex texts. 

The project was born out of the need to overcome the limitations of simple chat interfaces, especially when using Language Models (LLMs) such as ChatGPT for prompts about complex software projects or for writing extensive texts. Some of the challenges include:

-   Limited editor capabilities of chat interfaces
-   The cumbersome process of composing prompts by copying and pasting project knowledge repeatedly, leading to outdated and duplicated fragments
-   The lack of efficient methods to manage and organize knowledge in chat interfaces

Magma addresses these issues by providing a comprehensive environment for project knowledge bases and prompt development. It capitalizes on [Obsidian](https://obsidian.md/), a versatile tool for knowledge management, that works on top of a local folder of plain text Markdown files. Obsidian serves as the user interface for managing project knowledge and as an editor for producing documentation from the contained knowledge. For more details about Obsidian, please visit the [Obsidian Help site](https://help.obsidian.md/Home).

Although Magma is designed for use with Obsidian, it's worth noting that since Obsidian documents are essentially Markdown documents, Magma could be used without Obsidian by manually using the Mix Tasks and a Markdown editor of your choice.

> #### info {: .info}
>
> In the first version of Magma, only the OpenAI API is supported for automatic prompt execution. However, the system is designed with an LLM adapter facility that allows for the implementation of other LLMs in the future. Additionally, manual prompt execution is supported, which can be used to execute the prompts with anything you want.

## The Basic Idea

The fundamental concept behind Magma is straightforward:

- You, the user, collect project-relevant knowledge in "[Atomic Notes](https://www.dsebastien.net/the-value-of-atomic-notes/)" within an Obsidian vault. Atomic notes are individual units of knowledge that focus on one specific idea or concept. 

- Using [transclusions](https://en.wikipedia.org/wiki/Transclusion) — a concept borrowed from hypertext that allows for the insertion of the content of a document into another document — you can generate LLM prompts that contain the necessary knowledge for the LLM. Magma's transclusion resolution feature ensures that prompts consisting of transclusions are compiled into a proper prompt before execution.

- In addition to user-defined custom prompts, Magma also defines a system of documents for a predefined workflow with predefined (but editable) prompts for the generation of various documentation artefacts, such as ModuleDocs, project readme, etc., including longer texts, as user guides for example.

