<!-- ExDoc doesn't support YAML frontmatter

---
magma_type: Artefact.Version
magma_artefact: Article
magma_concept: "[[Magma User Guide - Current Limitations and Roadmap]]"
magma_draft: "[[Generated Magma User Guide - Current Limitations and Roadmap (article section) (2023-11-01T17:23:14)]]"
created_at: 2023-11-01 17:28:03
tags: [magma-vault]
aliases: []
---

-->

# Current Limitations and Roadmap

Magma is still in its early stages of development. While it already provides a useful environment for creating and executing complex prompts, it has some limitations and rough edges. 

## Limitations

- The shell commands triggered by the buttons on the various Magma documents are only tested under macOS. If you're experiencing problems under Linux or Windows, please report them on [this issue](https://github.com/marcelotto/magma/issues/1). If they work on one of these systems for you, please also confirm this on this issue.
- The table of contents of a text cannot be easily modified after the initial section creation.
- Intra-document transclusions (transclusions of sections inside the same document) are not supported due to a coarse transclusion recursion detection.
- Previous artefact versions are not automatically backed up when selecting a new one, you'll have to use the Mix task to overwrite previous ones or delete them manually.
- The moduledoc prompts produce mixed results and need further refinements.

## Roadmap

Main goals for the next versions are:

- Improving the process of changing the table of contents of a text after the initial section creation.
- Supporting intra-document transclusions.
- Implementing automatic backup for previous artefact versions when creating a new one.
- Adding support for generating a project website.

## Contributing to Magma

Magma is an open-source project, and we welcome contributions from the community. If you'd like to help and contribute to the project, there's plenty of opportunities. Here are just some suggestions:

- Test shell commands under Linux and Windows (see [this issue](https://github.com/marcelotto/magma/issues/1))
- Simplifying the setup for non-Elixir users by creating a CLI and a self-contained binary with something like [Burrito](https://github.com/burrito-elixir/burrito).
- Improving prompts.
- Adding more text types.
- Creating more artefacts for projects (like Project descriptions, Announcements for various sites/platforms) and modules (like Cheatsheets, Test factories, Test properties).
- Adding more matter types like versions and tasks (stories, issues etc.).
- Implementing support for module stereotypes (e.g. for GenServer, Mix tasks etc.) with more specific prompts.
- Adding support for other LLMs (via `Magma.Generation` adapters).
- Implementing support for other languages than Elixir.

I'm excited about the future of Magma and hope you are too. Together, we can make Magma a powerful tool for developers and writers alike.
