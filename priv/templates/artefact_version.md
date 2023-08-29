---
magma_type: Artefact.Version
magma_prompt_result: "<%= link_to(prompt_result) %>"
created_at: <%= version.created_at %>
tags: <%= yaml_list(version.tags) %>
aliases: <%= yaml_list(version.aliases) %>
---
<%= Magma.Document.content_without_prologue(prompt_result) %>