---
magma_type: Artefact.Prompt
magma_artefact: ModuleDoc
magma_concept: "<%= link_to(concept) %>"
created_at: <%= prompt.created_at %>
tags: <%= yaml_list(prompt.tags) %>
aliases: <%= yaml_list(prompt.aliases) %>
---
<%= button("Update", "magma.prompt.update") %>

# <%= prompt.name %>

## Setup


## Request

