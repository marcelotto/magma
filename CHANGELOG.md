# Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com).


## Unreleased

### Added

- New document type `Magma.Session` for storing and managing Claude Code conversations within Magma
- New link resolution style `:at_file_ref` which replaces links with the file path of the linked
  document in the form `@"path/to/file.md"`, that is used by many coding agents (Claude Code,
  Cursor etc.) to reference files
- Support for Elixir v1.16

### Changed

- Change name of custom prompt directory from `custom_prompts/` to `prompts/`
- No longer dependent on Rambo causing troubles in MacOS

### Fixed

- No longer produce invalid prompt result filenames with colons (in the timestamp)

[Compare v0.2.0...HEAD](https://github.com/marcelotto/magma/compare/v0.2.0...HEAD)



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
