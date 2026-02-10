# Vault Structure & Configuration

A Magma vault is an Obsidian-compatible directory containing your project knowledge, prompts, and sessions. This section explains the vault structure and configuration options.

## Directory Layout

```
<vault>/
├── sessions/                # Multi-turn conversation logs
│   └── .responses/          # (Internal) Temp files for response import
├── prompts/                 # Standalone, single-use prompts
│   └── __prompt_results__/  # Results of prompt executions
├── templates/               # Blueprint files for new documents
│   ├── session.md
│   ├── custom_prompt.md
│   └── session_continuation.md
├── magma.config/            # Global settings
│   └── Magma.system.config.md
├── .obsidian/               # Obsidian-specific settings and plugins
└── .magma.version           # Version marker
```


## Key Directories

### `sessions/`

The heartbeat of Magma. This is where you conduct multi-turn chats with coding agents. 

### `prompts/`

Used for tasks that don't require a long conversation—like "Refactor this function" or "Generate a unit test." 

> #### Git Notice {: .info}
> The `__prompt_results__/` subdirectory is excluded from version control by default via the vault's `.gitignore`, as these results are often temporary and project-specific.

### `templates/`

When you create a new session or prompt, Magma uses these files as a starting point. You can (and should!) customize these to fit your personal workflow.

## System Configuration

Global settings live in `magma.config/Magma.system.config.md`. This file uses **YAML frontmatter** for technical settings and **Markdown sections** for global context.

### YAML Settings

- `link_resolution_style`: How internal links are resolved (see [Transclusion Resolution](03-transclusion.html)).
- `include_prompt_header`: Whether to include the top-level header in compiled prompts (default: `true`)


### Markdown Settings (The "Global Context")

The `Magma.system.config.md` file contains special sections like `## Persona` and `## Context knowledge`. These are not automatically added to every prompt, but they are ready to be transcluded whenever you need them.

**Example: Adding your global persona to a prompt**

In your prompt file, just add:

```markdown
![[Magma.system.config#Persona|]]
```


## Vault Discovery

Magma is smart about finding your vault. It looks in this order:

1.  **`MAGMA_VAULT_PATH`** (Environment Variable)
2.  **Current Directory** (If it contains a `magma.config/` folder ( i.e., you're inside the vault)
3.  **`.magma.yaml`** (Project-level config file in your project root)
4.  **`magma/`** (Fallback to the default folder name)

> #### Tip {: .tip}
> If you have multiple projects and want to keep one central vault, set the `MAGMA_VAULT_PATH` in your `.zshrc` or `.bashrc`.