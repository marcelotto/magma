---
magma_type: Concept
magma_matter_type: Module
created_at: <%= concept.created_at %> 
tags: <%= yaml_list(concept.tags) %>
aliases: <%= yaml_list(concept.aliases) %>
---
# `<%= concept.name %>`

## <%= Magma.Concept.description_section_title() %>

What is a `<%= concept.name %>`?

Facts, problems and properties etc. - your knowledge - about the module.


---
## Notes


---
# <%= Magma.Concept.system_prompt_section_title() %>

## Commons


## ModuleDoc

<%= link_to_prompt(concept, Magma.Artefacts.ModuleDoc) %>

### Spec

### Draft



## Cheatsheet



---
# Reference

