---
magma_type: Concept
magma_matter_type: Project
magma_matter_name: <%= subject.name %> 
created_at: <%= concept.created_at %>
tags: <%= yaml_list(concept.tags) %>
aliases: <%= yaml_list(concept.aliases) %>
---
# <%= subject.name %> project

## <%= Magma.Concept.description_section_title() %>

<!-- 
What is the <%= subject.name %> project about?

Facts, problems and properties etc. - your knowledge - about the project.
-->


---
## Notes


---
# <%= Magma.Concept.system_prompt_section_title() %>

## Commons


## ModuleDoc


## Cheatsheet


---
# Reference

