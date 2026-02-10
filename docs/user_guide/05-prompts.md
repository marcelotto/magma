# Working with Prompts

Prompts in Magma are specialized Markdown files where you "engineer" your instructions before sending them to an LLM. 


## 1. Creating a Prompt

You can create a new prompt document in two ways:

- **CLI**: `magma prompt.gen "Refactor function"`
- **Obsidian**: Use the hotkey `Cmd-Ctrl-P` (QuickAdd: Custom Magma prompt).

This creates a file in your `prompts/` folder using the standard template.

> #### Naming Convention {: .tip}
> Just like any Obsidian document, prompt names must be unique. A good practice is to use a prefix like "Prompt for ..." to prevent conflicts with other documents.

## 2. Anatomy of a Prompt Document

A standard Magma prompt document is divided into three functional areas:

### Prologue (Buttons)

At the top, you'll see buttons like **"Copy to clipboard"**. These use Obsidian plugins to trigger the Magma CLI.

### Context Section

This is where you gather the knowledge required for the task. 
- Use **transclusions** (`![[...]]`) to include project docs.
- Use **links** (`[[...]]`) for minor references.
- *LLM Tip*: When using an API integration, this section is sent as the **System Prompt**.

### Task Section

This is where you write your actual request (e.g., "Please refactor the following Elixir code for better performance..."). 


## 3. The "Copy-Paste" Workflow

This is the most reliable and common way to use Magma:

1.  **Draft**: Prepare your prompt in Obsidian using transclusions for context.
2.  **Compile & Copy**: Click the **"Copy to clipboard"** button (or run `magma copy-prompt "Prompt Name"`).
    - Magma resolves all transclusions and converts links to plain text.
3.  **Paste**: Go to your favorite AI (ChatGPT, Claude.ai, etc.) and paste the result.


## 4. The "Manual Execution" Workflow

If you want to keep a record of the AI's response inside your vault:

1.  Click **"Execute manually"** in Obsidian.
2.  Magma copies the prompt to your clipboard and creates a new **Prompt Result** file in `prompts/__prompt_results__/`.
3.  Paste the prompt into your AI and get the response.
4.  Copy the AI's response and paste it back into the result file in Obsidian.

This workflow is excellent for maintaining a history of "prompt experiments" and their outcomes.

> #### Git Notice {: .info}
> As mentioned in the Vault Structure section, the `__prompt_results__/` directory is excluded from version control by default.

> #### Note on Automatic Execution {: .info}
> The automatic prompt execution feature (`magma exec-prompt` without `--manual`) has not been maintained and likely does not work with current LLM APIs. This is why prompt documents no longer include an "Execute" button. The manual workflow described should work, but this area is not well tested and may need updates. Contributions welcome!
