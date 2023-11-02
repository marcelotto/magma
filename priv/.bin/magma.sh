#!/usr/bin/env bash
# magma.sh - A script to invoke Mix tasks in a portable manner from
# the Obsidian vault, in particular the obsidian-shellcommands plugin

# Load asdf environment if asdf is installed
if [ -f "$HOME/.asdf/asdf.sh" ]; then
    source "$HOME/.asdf/asdf.sh"
elif [ -f "$HOME/.asdf/asdf.fish" ]; then
    source "$HOME/.asdf/asdf.fish"
fi

# Check if `mix` is available
if ! command -v mix &>/dev/null; then
    echo "Mix command could not be found. Please ensure Elixir is installed via asdf and in your PATH."
    exit 1
fi

# Navigate to the main project directory
cd "$(dirname "$0")/../.." || exit

# Load environment variables if .envrc exists
if [ -f ".envrc" ]; then
  source .envrc
fi

# Execute the Mix task
mix "$@"
