# Roadmap & Contributions

Magma is an evolving project designed to bridge the gap between project knowledge and coding agents.

## Project Philosophy

Magma was created primarily as a personal tool to streamline my personal workflow across a variety of other projects. Consequently, the core development focus is on features and improvements that provide direct value to my daily work. This approach ensures that Magma remains a robust, practical tool for its original purpose while allowing me to maintain focus on my primary development tasks.

## Current Limitations

- **Platform Focus**: The Obsidian integration (buttons and hotkeys) is primarily optimized for **macOS**. While the core CLI works on Linux, some UI elements may require manual configuration on this platform.
- **Agent Compatibility**: The "Response Import" workflow has been extensively tested with **Claude Code**. Other agents may require different response instructions.
- **Intra-document Transclusion**: You currently cannot transclude a section from the *same* document you are working in.
- **Legacy Features**: Some early features, like direct LLM API execution (`magma exec-prompt`), are currently unmaintained as we focus on the more popular coding agent workflows.

## How to Contribute

Contributions from the community are welcome! Whether you are a developer, a technical writer, or a power user, there are several ways to help:

### 1. Feedback & Documentation

- **Test on other platforms**: If you use Linux, please report any issues you find. Your feedback helps improve cross-platform stability.
- **Improve the Documentation**: If you find any part of this guide confusing or identify a typo, please submit a Pull Request.

### 2. Code Contributions

- **Bug Fixes**: Check the [GitHub Issues](https://github.com/marcelotto/magma/issues) for open bugs.
- **New Features**: If you have an idea for a new feature, please open a [Discussion](https://github.com/marcelotto/magma/discussions). Please understand that implementation priority is given to features that align with my personal requirements. For features outside this scope, **well-tested Pull Requests** are the most effective way to see them integrated.

---

### Resources

- **GitHub Repository**: [marcelotto/magma](https://github.com/marcelotto/magma)
- **Discord/Forum**: [GitHub Discussions](https://github.com/marcelotto/magma/discussions)
- **License**: MIT