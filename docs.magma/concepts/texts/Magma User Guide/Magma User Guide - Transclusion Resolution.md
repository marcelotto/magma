---
magma_type: Concept
magma_matter_type: Text.Section
magma_section_of: "[[Magma User Guide]]"
created_at: 2023-10-20 09:53:32
tags: [magma-vault]
aliases: []
---
# Transclusion Resolution

## Description

Abstract: This section introduces the basic concepts of transclusions and atomic notes. It then provides an understanding of the process of transclusion resolution in Magma. It covers the different types of transclusions and how they are resolved, along with the processing steps applied during transclusion resolution.

Outline:

- Since we can not assume all readers are familiar with the general concept of a transclusion, it should be introduced properly. 
- Then provide a longer explanation of the importance of atomic notes
	- in general, 
	- in conjunction with transclusions 
	- and then why they are in important in Magma, where we want to compose our prompts from atomic knowledge snippets to feed them into an LLM . 
- Explain why transclusions are an appropriate method for prompt composition and why they must be resolved/substituted with the transcluded content. 
- Then move into a detailed introduction to tranclusion resolution in Magma. 
	- Point out the Obsidian-Magma transclusion presentation mismatch problem in a side-note.
	- Point out the current intra-document transclu in a side-note.


### Explanation of the general concept of transclusions

Transclusions are a concept in computer science and digital publishing to refer to the inclusion of a document or part of a document into another document by reference. Essentially, instead of copying the content directly, you insert a piece of code or a directive that tells the system to fetch and embed the content from the original location. This means that the content is not duplicated; instead, the original content is displayed in a new location, but it is still maintained in a single place.

Here are some key points about transclusions:

1. **Dynamic Content Updating**: When the original content is updated, the changes are automatically reflected wherever the content has been transcluded. This ensures consistency across different parts of a digital ecosystem.
   
2. **Efficiency**: Transclusion helps in reducing redundancy and saves storage space, as the same content doesn't need to be stored in multiple places.

3. **Content Management**: It simplifies content management by allowing a single source of truth for content that might need to be displayed in multiple locations.

Transclusion can be a powerful tool for content creators and developers, allowing for more flexible and maintainable content structures.

In Obsidian transclusions are written like this `![[Some Document]]`.

Note, that in Obsidian with support for transclusions of sections (`![[Some Document#Some Section`), notes must not necessarily be composed into dedicated documents. When appropriate atomic notes can be grouped as sections in a document, like files in folders.

### Importance of atomic notes

Atomic notes, in the context of systems where transclusions are used extensively (like Magma), refer to the practice of creating small, self-contained notes that capture a single idea, topic, or piece of information. These notes are "atomic" in the sense that they are indivisible in their content focus. The importance of atomic notes in such systems is multifaceted:

- **Reusability**: Atomic notes can be easily transcluded in various contexts without carrying over irrelevant information. Because they focus on a single concept, they can be used wherever that concept is relevant.
- **Maintainability**: With atomic notes, updates need to be made in only one place. This ensures that all transclusions of the note are up-to-date, thus maintaining consistency across the entire system.
- **Composability**: Just like building blocks, atomic notes can be combined in various ways to construct more complex ideas or documents. This modularity allows for flexible content creation.
- **Clarity**: Each atomic note serves a specific purpose and addresses a specific point, which makes the overall content system clearer and more digestible for both the author and the audience.
- **Scalability**: As the system grows, atomic notes ensure that the expansion is manageable. It's easier to add, modify, or deprecate small chunks of content than to revise large, monolithic documents.

In systems where transclusions are a core feature, atomic notes are the cornerstone that enables efficient and dynamic content management, providing a robust and agile way to handle information.

### Explanation of Transclusion resolution in Magma 

[Feel free to reorganize the content in this section. Please use a better example than the lorem ipsum text.]

![[Magma-Transclusion-Resolution#Description with examples]]

### ![[Magma-Transclusion-Resolution#Obsidian-Magma transclusion presentation mismatch problem]]
### Current limitation: Intra-document transclusion resolution not supported yet ![[Limitations#Intra-document transclusion resolution]]




# TODO

## ![[Magma-Transclusion-Resolution#Optional longer descriptions with local transclusions]]

# Context knowledge

<!--
This section should include background knowledge needed for the model to create a proper response, i.e. information it does not know either because of the knowledge cut-off date or unpublished knowledge.

Write it down right here in a subsection or use a transclusion. If applicable, specify source information that the model can use to generate a reference in the response.
-->




# Artefacts

## Article

- Prompt: [[Prompt for Magma User Guide - Transclusion Resolution (article section)]]
- Final version: [[Magma User Guide - Transclusion Resolution (article section)]]

### Article prompt task

Your task is to write the section "Transclusion Resolution" of "Magma User Guide" in round about 2000 words.

![[ExDoc#Admonition blocks]]

![[Prompt snippets#Editorial notes]]

![[Prompt snippets#Cover all content]]
