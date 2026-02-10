# Introduction

**Magma** is a specialized Integrated Development Environment (IDE) for building, managing, and refining prompts for coding agents like Claude Code, OpenCode, and other AI-powered tools. 

While modern coding agents are incredibly powerful, they often suffer from the limitations of simple chat interfaces. Magma was created to bridge the gap between "just chatting" and professional prompt engineering.

### Why Magma?

Working with Language Models (LLMs) for complex tasks presents several challenges:

- **Limited Tooling**: Standard chat interfaces lack the sophisticated editor capabilities needed for complex prompt architecture.
- **Fragile Context**: Copying and pasting project knowledge repeatedly is cumbersome and error-prone.
- **Outdated Snippets**: Maintaining "source of truth" documentation across multiple chat sessions is nearly impossible.
- **Lack of Reusability**: Hard-earned prompt structures are often lost in chat history rather than being treated as reusable assets.

Magma solves these problems by providing a robust environment where your project knowledge and your prompts live together in a structured, version-controlled vault.


## Core Concept: Prompts as Code

The fundamental philosophy of Magma is that **prompts should be treated like code**: they should be modular, reusable, and composed of well-defined parts.

- **Atomic Notes**: You capture project-relevant knowledge in small, focused units within a Magma vault. These "Atomic Notes" are your building blocks.
- **Transclusion**: Instead of copying text, you *include* it. Magma uses transclusions (references to other notes) to assemble prompts dynamically. When you update a note, every prompt using it is automatically updated.
- **Session-Driven Workflow**: Magma moves beyond "one-shot" prompts to structured sessions that maintain conversation history.


## Powered by Obsidian

Magma is built to work seamlessly with [Obsidian](https://obsidian.md/), which provides one of the best environments for writing and managing Markdown.

- **Superior Editor**: Benefit from a highly polished Markdown editing experience.
- **Visual Management**: Organize your knowledge base and prompts using Obsidian's folders, tags, and graph view.
- **Extensible**: Benefit from Obsidian's vast ecosystem of plugins.

While Magma is optimized for Obsidian, it is fundamentally a CLI tool that works with plain Markdown files. You can use it with any editor, but Obsidian provides the best "IDE-like" experience.

For more details about Obsidian, please visit the [Obsidian Help site](https://help.obsidian.md/Home).