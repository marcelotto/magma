---
magma_type: Concept
magma_matter_type: Project
magma_matter_name: Magma
created_at: 2023-10-06 16:03:10
tags: [magma-vault]
aliases: [Magma project, Magma-project]
---
# Magma project

## Description

Magma is an environment for writing and executing complex prompts.
Although its primary use case for now is supporting developers (for the time being esp. Elixir devs) for collecting knowledge about their project, generating documentation or solving other problems with LLM prompts using the created knowledge base, it can already be useful outside of this context too, e.g. when you want to generate longer texts.

It builds Obsidian as the user interface to the knowledge about the project and the editor for producing documentation from the contained knowledge. But at its core Magma is just a bunch of Mix tasks processing existing and generation new Markdown documents. The Mix Tasks are triggered from within Obsidian either via buttons (with the Obsidian Button and ShellCommand plugins) or commands (with the QuickAdd plugin). However, since Obsidian documents essentially are only Markdown documents, Magma, could be used also without Obsidian at all by using the Mix Tasks manually and a user-chosen Markdown editor. But the whole workflow is currently tailored for use with Obsidian.

The basic idea: 

- The user collects his project-relevant knowledge in "Atomic Notes" in an Obsidian vault.
- Using transclusions, he can now easily generate prompts for LLMs that contain the knowledge required for the LLM. The [[Magma-Transclusion-Resolution|Transclusion Resolution]] feature implemented by Magma ensures that prompts consisting of transclusions are compiled into a proper prompt before execution.
- In addition to user-defined custom prompts, Magma also defines a system of documents for a predefined workflow with predefined (but editable) prompts for the generation of various documentation artefacts (such as ModuleDocs, project readme, user guides etc.) (later also development artefacts such as test factories, test properties etc.)  [see [[Magma artefact model]] ].

### Features

- a transclusion resolution system allowing to compose prompts very quickly from existing content
- extendible workflows for the generation of various artefacts, e.g.
	- project README
	- module docs
	- larger texts (which would go beyond the usual token limits of LLMs)
- support for automatic prompt execution via the OpenAI API or manually with via the chat interface of the LLM of your choice (ChatGPT, Bard, Claude etc.)
- keeps all created files in a nicely organized folder structure
- with Obsidian's vast plugin eco system the environment can be adapted to many use cases


# Context knowledge

## Obsidian

I assume you're familiar with Obsidian and Obsidian Markdown.

## LLMs

I assume you're familiar with LLMs and ChatGPT.




# Artefacts

## README

- Prompt: [[Prompt for README]]
- Final version: [[README]]

### Readme prompt task

Generate a README for project 'Magma' according to its description and the following information:  
  
Hex package name: magma
Repo URL: https://github.com/marcelotto/magma
Documentation URL: https://hexdocs.pm/magma/
Homepage URL:  
Demo URL:  n/a
Logo path: logo.jpg  
Screenshot path:  
License: MIT License  
Contact: Marcel Otto - [@marcelotto](https://twitter.com/marcelotto)
Acknowledgments:  NLnet Foundation for funding this project
  
("n/a" means not applicable and should result in a removal of the respective parts)

