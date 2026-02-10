# Installation

Getting started with Magma involves setting up the CLI tool and initializing your workspace (the "Vault").

> #### Platform Support {: .warning}
> Magma is tested on **macOS** only. While it is designed to be cross-platform (Linux binaries are provided), you may encounter issues. Please report any new bugs by opening an issue. If you find that Magma runs well on your Linux system, providing feedback on [issue #1](https://github.com/marcelotto/magma/issues/1) would be very valuable!


## 1. Prerequisites

Before installing Magma, ensure you have the following tools:

### Pandoc (Required)

Magma uses [Pandoc](https://pandoc.org/) for high-fidelity Markdown processing and transclusion resolution.
- **Requirement**: Version 3.1.7 or higher.
- **Install**: See the [Pandoc installation guide](https://pandoc.org/installing.html).

### Obsidian (Recommended)

While optional, [Obsidian](https://obsidian.md/) provides the visual "IDE" experience for Magma.
- **Requirement**: Version 1.4 or higher (for full YAML frontmatter support).
- **Install**: Download from [obsidian.md](https://obsidian.md/).


## 2. Installing the CLI

### Option A: Homebrew (Preferred)

If you use [Homebrew](https://brew.sh/), you can install Magma with:

```bash
# Add the tap
brew tap marcelotto/tap

# Install Magma
brew install magma
```

### Option B: Manual Installation

1.  **Download**: Get the latest binary for your platform from the [GitHub Releases](https://github.com/marcelotto/magma/releases).
2.  **Make Executable**:
    ```bash
    chmod +x magma_macos_arm
    ```
3.  **Move to PATH**:
    ```bash
    mv magma_macos_arm /usr/local/bin/magma
    ```

### Verify Installation

```bash
magma version
```


## 3. Initializing Your Vault

A Magma "Vault" is simply a folder where your knowledge base and prompts live. You should typically initialize one per project (or one large one for multiple related projects).

### Default Initialization
Run this in your project root to create a `magma/` folder:
```bash
magma init
```

### Custom Location
If you prefer a different name or location (e.g., `docs.magma/`):
```bash
magma init docs.magma
```
This will create a `.magma.yaml` file in your current directory, telling the CLI where to find your vault.


## 4. Setup in Obsidian

Once your vault is initialized:

1.  **Open Obsidian**.
2.  **Open folder as vault**: Select the folder you just created (e.g., `magma/` or `docs.magma/`).
3.  **Trust Plugins**: Magma initializes the vault with a pre-configured `.obsidian` folder containing essential plugins (like `Shell Commands`). When prompted, click **"Trust author and enable plugins"**.

These plugins enable the buttons and hotkeys that make the Magma workflow so efficient.