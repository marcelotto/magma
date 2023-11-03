---
magma_type: Concept
magma_matter_type: Text.Section
magma_section_of: "[[Magma User Guide]]"
created_at: 2023-10-20 09:53:35
tags: [magma-vault]
aliases: []
---
# Current Limitations and Roadmap

## TODO

- Extract to atomic note for reuse in README arteface
- Pandoc quirks:
	- four character indentation of enumerations 
	- sections after an enumeration without blank lines in between are not detected
- Add links to created open issues

## Description

Abstract: This section outlines the limitations of the first MVP version of Magma. It provides a clear understanding of what Magma can and cannot do in its current version. It also provides a roadmap for Magma's future development and explains how users can contribute to its development. It encourages users to participate in the project and contribute to its growth.

Magma is still at its early stage and rough at it's edges. However, it's already quite usable. This user guide and parts of the API documentation were generated with it. But there's plenty of things to do.

This project started as a side project while working on another project, for which I was trying to generate the documentation using ChatGPT. I'd like finish the following things on Magma before continue with finishing the other project.

- System prompts are currently hard-coded in the Elixir implementation of the artefact types. I'd like move them into the Magma vault, so they can be edited or extented to your needs from within Obsidian. Ideally, new artefacts could be defined completely in Obsidian without having to touch the Magma codebase. We'll see how close we get to this goal.
- Improving changing the table of contents of a text after the initial section creation
- Support for intra-document transclusions, i.e. translusions of sections inside the same document, which is prohibited currently due to a too coarse transclusion recursion detection. However, support of such transclusions would support a very useful pattern for defining different large versions of a text.
- Previous artefact versions should be backup'd when creating a new one. Currently, you'll have to use the Mix task to overwrite previous ones or delete them manually, since the "Select as draft version" button doesn't support overwriting.
- Support for generating a project website


This means, however, I won't have time to work on other feature request for some time. But I'd be happy to accept PRs. If you'd to like help and contribute to the project, there's plenty of opportunity. Here are just some suggestions:

- proper shell commands for Linux and Windows (see issue #1)
- simplify setup for non-Elixir users by creating a CLI and a self-contained binary with something like [Burrito](https://github.com/burrito-elixir/burrito)
- prompt improvements
- more text types
- more artefacts
	- for projects
		- Project descriptions (for Hex packages, GitHub)?
		- Announcements for various sites/platforms
	- for modules
		- Cheatsheets
		- Test factories
		- Test properties
	- for texts
		- Presentation slide deck
		- Screencast scripts (for systems like [Synthesia](https://www.synthesia.io/), [HeyGen](https://www.heygen.com/) etc.)
- more matter types
	- versions
	- tasks (stories, issues etc.)
- support for module stereotypes (e.g. for GenServer, Mix tasks etc.) with more specific prompts
- support for other LLMs (via `Magma.Generation` adapters)
- support for other languages than Elixir
- 

# Context knowledge




# Artefacts

## Article

- Prompt: [[Prompt for Magma User Guide - Current Limitations and Roadmap (article section)]]
- Final version: [[Magma User Guide - Current Limitations and Roadmap (article section)]]

### Article prompt task

Your task is to write the section "Current Limitations and Roadmap" of "Magma User Guide".

![[ExDoc#Admonition blocks]]

![[Prompt snippets#Editorial notes]]

![[Prompt snippets#Cover all content]]
