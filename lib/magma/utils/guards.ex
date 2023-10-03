defmodule Magma.Utils.Guards do
  @moduledoc !"A collection of guards intended for internal use."

  defguard is_ordinary_atom(term)
           when is_atom(term) and term not in [nil, true, false]

  defguard maybe_module(term) when is_ordinary_atom(term)

  defguard is_prompt(prompt)
           when is_struct(prompt, Magma.Artefact.Prompt) or is_struct(prompt, Magma.Prompt)
end
