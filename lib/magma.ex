defmodule Magma do
  @moduledoc """
  Magma is a prompt development environment for working with coding agents.

  It provides a knowledge base system built on Obsidian-compatible markdown documents
  that enables rapid composition of prompts through transclusions. The session-based
  workflow supports iterative conversations with coding agents like Claude Code, Codex,
  Gemini CLI, OpenCode etc.

  Read the [User Guide](01-introduction.md) to learn more.
  """

  def version do
    Application.spec(:magma)[:vsn] |> List.to_string() |> Version.parse!()
  end
end
