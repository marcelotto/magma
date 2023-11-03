---
magma_type: Concept
magma_matter_type: Text.Section
magma_section_of: "[[Magma User Guide]]"
created_at: 2023-10-20 14:02:44
tags: [magma-vault]
aliases: []
---
# Installation and setup

## TODO

- [[Versioning the Magma vault]]
- Problem with Shellcommands on other systems

## Description

Abstract: This section explains how install and setup Magma within an Elixir project.

Warning: Magma has only been tested with MacOS so far, although there is nothing that prevents it from running on other systems as well (all components used also run on Windows and Linux), 

As mentioned in the introduction, although Magma is currently focused on use in Elixir projects, it is also generally applicable and useful. The following instructions however assume you already have an Elixir project in which Magma will be installed. So, if you want to use Magma for such general usage, read the "Installation for non-Elixir devs" section at the end before continuing here.

### Installation in an existing Elixir project ![[Installation and setup#in an existing Elixir project]]

### ![[Magma vault creation#Magma vault creation]]

![[Magma document creation defaults]]

If you want have this tag on all created documents, be sure to have this configured before the initial vault creation.

[The code sync should be introduced as a side-effect of the vault creation section. The resp. mix task for subsequent execution should be mentioned in a side-note.]

### ![[Code sync#Code sync]]

### Installation for non-Elixir devs

First, you'll have to install Erlang and Elixir following [this guide](https://elixir-lang.org/install.html).

Then go to the directory where you want to create the Magma vault with your Markdown files and run the following command with the name of the directory and change into this directory. 

```sh
$ mix new my_magma_vault
$ cd my_magma_vault
```

Now, you can continue with the "Installation in an existing Elixir project" above. A few remarks, however, which are not mentioned there, since they are basic Elixir knowledge:

- After editing the deps in the `mix.exs` file, you'll have to do the following to actually fetch the specified dependencies:
	```sh
	$ mix deps.get
	```
- Since your not interested in documenting code, you should add the `--no-code-sync` option during vault initialization:
	```sh
	$ mix magma.vault.init "Name of your project" --no-code-sync
	```



# Context knowledge

## Magma vault ![[Magma.Vault#Description]] 




# Artefacts

## Article

- Prompt: [[Prompt for Magma User Guide - Installation and setup (article section)]]
- Final version: [[Magma User Guide - Installation and setup (article section)]]

### Article prompt task

Your task is to write the section "Installation and setup" of "Magma User Guide". 

![[Prompt snippets#Cover all content]]

![[Prompt snippets#Editorial notes]]

![[ExDoc#Admonition blocks]]
