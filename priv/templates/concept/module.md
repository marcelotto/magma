---
magma_type: Concept
magma_matter: Module
created_at: <%= concept.created_at %> 
tags: <%= yaml_list(concept.tags) %>
aliases: <%= yaml_list(concept.aliases) %>
---
# `<%= concept.name %>`

## Description

What is a `<%= concept.name %>`?

Facts, problems and properties etc. - your knowledge - about the module.


---
## Notes


---
# Artefacts

## Commons


## ModuleDoc

<%= transclude_prompt(concept, Magma.Artefacts.ModuleDoc) %>


### Spec

### Draft



## Cheatsheet



---
# Reference

