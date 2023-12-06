# Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/) and
[Keep a CHANGELOG](http://keepachangelog.com).


## Unreleased

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

[Compare v0.1.1...HEAD](https://github.com/marcelotto/magma/compare/v0.1.1...HEAD)



## v0.1.1 - 2023-11-03

### Fixed

- a regression of the `Mix.Tasks.Magma.Prompt.Copy` Mix task

[Compare v0.1.0...v0.1.1](https://github.com/marcelotto/magma/compare/v0.1.0...v0.1.1)



## v0.1.0 - 2023-11-03

Initial release
