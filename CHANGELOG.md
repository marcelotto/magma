# Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com).


## v0.3.0 - 2026-02-10

This release marks a fundamental reorientation of Magma. Originally designed as an
Elixir-based environment for generating documentation and other artefacts through
direct LLM execution, Magma has been redesigned as a prompt IDE for coding agents
like Claude Code, OpenCode, etc. The focus has shifted from executing prompts
within Magma itself to composing prompts from project knowledge that are used in
external coding agents. Key changes include a standalone CLI binary (no Elixir
installation required), a new Session document type for multi-turn conversations,
file reference syntax for coding agent compatibility, and the removal of the
Matter/Artefact system in favor of a simpler, more flexible prompt-centric workflow.

### Added

- Standalone CLI binary (via Burrito) for use without Elixir installation
- Vault discovery system with 5-level hierarchy (env var, current dir, `.magma.yaml`, app config, fallback)
- New document type `Magma.Session` for storing and managing Claude Code conversations within Magma
- New link resolution style `:at_file_ref` which replaces links with the file path of the linked
  document in the form `@"path/to/file.md"`, that is used by many coding agents (Claude Code,
  Cursor etc.) to reference files
- New system config option `:include_prompt_header` to control whether the top-level header is
  included in compiled prompts and sessions (can be overridden per document via frontmatter)
- Support for newer Elixir versions

### Changed

- Default vault directory changed from `docs.magma/` to `magma/`
- File paths in `@`-references are now relative to vault parent directory
- Change name of custom prompt directory from `custom_prompts/` to `prompts/`
- Default prompt/session template now uses "Context" (with "Knowledge Base" subsection) and "Task"
  sections instead of "System prompt" and "Request". The old section names are still recognized as
  fallbacks. The "Context" section is now optional. Persona and context knowledge transclusions are
  no longer included by default but can be added to templates manually.
- Prompts and initial session prompts now include the top-level header by default (previously
  always removed) for better context visibility in coding agent history previews (e.g., Claude Code)
- No longer dependent on Rambo causing troubles in MacOS
- Drop support for Elixir versions < 1.15

### Removed

- the complete Matter/Artefact system

### Fixed

- No longer produce invalid prompt result filenames with colons (in the timestamp)

[Compare v0.2.0...v0.3.0](https://github.com/marcelotto/magma/compare/v0.2.0...v0.3.0)



## v0.2.0 - 2023-12-15

### Added

- Mix task `Mix.Tasks.Magma.Vault.Migrate` (`magma.vault.migrate`) to migrate a
  vault to a newer version
- Mix task `Mix.Tasks.Magma.Text.Type.New` (`magma.text.type.new`) to add
  new custom text types.

### Changed

- The configuration was moved into special config documents in the vault.
  These include in particular also the system prompts and default task prompts,
  which means they can now be easily adopted without having to touch any
  Elixir code.
- `Magma.Artefact` types are structs now, in order to support use cases
  where multiple artefact instances of the same type for one concept should
  be supported

### Fixed

- encoding issues with the "Copy to clipboard" button when the prompt contained 
  special characters 

[Compare v0.1.1...v0.2.0](https://github.com/marcelotto/magma/compare/v0.1.1...v0.2.0)



## v0.1.1 - 2023-11-03

### Fixed

- a regression of the `Mix.Tasks.Magma.Prompt.Copy` Mix task

[Compare v0.1.0...v0.1.1](https://github.com/marcelotto/magma/compare/v0.1.0...v0.1.1)



## v0.1.0 - 2023-11-03

Initial release
