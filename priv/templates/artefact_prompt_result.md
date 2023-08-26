---
magma_type: Artefact.PromptResult
magma_prompt: "<%= link_to(prompt) %>"
magma_generation_type: <%= Magma.Generation.short_name(result.generation) %>
magma_generation_params: <%= yaml_nested_map(result.generation) %>
created_at: <%= result.created_at %>
tags: <%= yaml_list(result.tags) %>
aliases: <%= yaml_list(result.aliases) %>
---
<%= result.content %>
