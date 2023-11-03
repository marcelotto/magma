---
magma_type: Concept
magma_matter_type: Module
created_at: 2023-10-06 16:03:15
tags: [magma-vault]
aliases: []
---
# `Magma.Vault.BaseVault`

## Description

A `Magma.BaseVault` is an Obsidian vault preconfigured with Obsidian themes and plugins that is used as a base when initializing a new Magma vault.  
  
Various such base vaults can be defined in the `priv/base_vault` folder. In the first version of Magma, however, only a default base vault is defined with the absolutely necessary or very essential plugins. Future plans include offering a more comprehensive base vault that leverages the extensive Obsidian plugin ecosystem or more domain-specific or user-contributed BaseVaults. The default BaseVault is also used when initializing a vault and no other BaseVault is specified.  

### Default base vault

- Theme: Default Obsidian theme
- Plugins
	- Required plugins which every base vault should include since without them some basic functionality doesn't work 
		- [Buttons](https://github.com/shabegom/buttons) (required for rendering the buttons)
		- [Shell commands](https://github.com/Taitava/obsidian-shellcommands) (required for executing the Magma Mix tasks)
		- [QuickAdd](https://github.com/chhoumann/quickadd) (required for triggering the custom prompt command)
		- [Dataview](https://github.com/blacksmithgu/obsidian-dataview) (required for rendering the table of prompt results in a prompt document for example)
	- Essential
		- [Better Word Count](https://github.com/lukeleppan/better-word-count)
		- [Editor Syntax Highlight](https://github.com/deathau/cm-editor-syntax-highlight-obsidian)
		- [Recent Files](https://github.com/tgrosinger/recent-files-obsidian)
		- [Paste URL into selection](https://github.com/denolehov/obsidian-url-into-selection)
		- [Hotkeys++](https://github.com/argenos/hotkeysplus-obsidian#hotkeysplus-obsidian)

### Creating a new base vault

Besides the required plugins from the default base vault also the configuration of the Shell Commands and QuickAdd plugins must copied as they contain the integration with the respective Magma mix tasks.

<!--
	- Reconsider as essential
		- [Pandoc Plugin](https://github.com/OliverBalfour/obsidian-pandoc)
		- [Advanced URI](https://github.com/Vinzent03/obsidian-advanced-uri)
-->

# Notes

## Potential plugins and themes


# Context knowledge
## ![[Magma vault creation#Vault initialization]]


# Artefacts

## ModuleDoc

- Prompt: [[Prompt for ModuleDoc of Magma.Vault.BaseVault]]
- Final version: [[ModuleDoc of Magma.Vault.BaseVault]]

### ModuleDoc prompt task

Generate documentation for module `Magma.Vault.BaseVault` according to its description and code in the knowledge base below. All parts of the description should be covered. Add a section with guidelines on how to create base vault (required plugins etc.)

