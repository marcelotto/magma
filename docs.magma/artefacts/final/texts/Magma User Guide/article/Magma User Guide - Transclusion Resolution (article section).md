<!-- ExDoc doesn't support YAML frontmatter

---
magma_type: Artefact.Version
magma_artefact: Article
magma_concept: "[[Magma User Guide - Transclusion Resolution]]"
magma_draft: "[[Generated Magma User Guide - Transclusion Resolution (article section) (2023-10-29T22:32:37)]]"
created_at: 2023-10-29 22:38:47
tags: [magma-vault]
aliases: []
---

-->

# Transclusion Resolution

Transclusion is a fundamental concept in Magma, playing a crucial role in the generation of prompts for LLMs. This section aims to provide an understanding of transclusions, atomic notes, and the process of transclusion resolution in Magma.

## What are Transclusions?

[Transclusions](https://en.wikipedia.org/wiki/Transclusion) refer to the inclusion of a document or part of a document into another document by reference. Instead of directly copying the content, a directive or a piece of code is inserted, instructing the system to fetch and embed the original content. This method ensures that the content is maintained in a single place and displayed in multiple locations as needed. 

The main advantages of transclusions are:

1.  **Dynamic Content Updating**: Changes made to the original content are automatically reflected wherever the content has been transcluded, ensuring consistency.
2.  **Efficiency**: Redundancy is reduced and storage space is saved as the same content doesn't need to be stored in multiple places.
3.  **Content Management**: Single source of truth for content that might need to be displayed in multiple locations simplifies content management.

In Obsidian, transclusions are written as `![[Some Document]]` or section transclusions  as `![[Some Document#Some Section]]`.

## Importance of Atomic Notes

Atomic notes are small, self-contained notes that capture a single idea, topic, or piece of information. They are indispensable in systems where transclusions are used extensively, such as Magma. Here's why:

- **Reusability**: Atomic notes can be easily transcluded in various contexts without carrying over irrelevant information.
- **Maintainability**: Updates made in one place ensure that all transclusions of the note are up-to-date, thus maintaining consistency across the entire system.
- **Composability**: Atomic notes can be combined to construct more complex ideas or documents, allowing for flexible content creation.
- **Clarity**: Each atomic note serves a specific purpose and addresses a specific point, enhancing the overall clarity of the content system.

Since Obsidian (and Magma) also support transclusions of section, atomic notes not necessarily need to be stored all in separate documents, but can be grouped as sections in a document, much like files in folders, when it is useful.

## Transclusion Resolution in Magma

Transclusion resolution in Magma refers to the process of resolving an Obsidian transclusion by replacing it with the referenced content. This is crucial for the composition of LLM prompts, which are defined as compositions of transclusions that must be resolved before the LLM execution, since the LLM can't access the referenced content. The content of the referenced document or document section is not inserted unchanged, however. Instead, it undergoes the following processing steps:

- Comments (`<!-- comment -->`) are removed.
- Internal links are replaced with the target (or their display text when available) as plain text.
- Transclusions within the transcluded content itself are resolved recursively (unless it would result in an infinite recursion)
- If the transcluded content (after removing the comments), consists exclusively of a heading with no content below it, the transclusion is resolved with the empty string.
- The level of the transcluded sections is adjusted according to the current level at the point of the transclusion.

There are three kinds of transclusions in Magma which are resolved slightly differently:

1. *Inline transclusions*: remove the leading header
2. *Custom header transclusions*: replace the leading header
3. *Empty header transclusions*: keep the leading header

Another difference between these transclusion resolution types is how they handle the prologue, i.e., text before the document title, on complete document transclusion resolutions. Both kinds of header transclusions omit prologue, while inline transclusions keep the prologue.

> #### warning {: .warning}
>
> Unfortunately, the different types of transclusion are not visible in Obsidian, as the first heading is always displayed there. This can become confusing, especially with nested transclusions.

To better understand the differences between transclusion types, let's consider an example document:

``` markdown
Some text before the document title like this, is called prologue in Magma.

# Some document

Id occaecat fugiat ea anim adipiscing.

## Some Section

Aliqua ea reprehenderit aliquip aliquip laborum.
```

1.  *Inline transclusions* stand alone in their own paragraph:

``` markdown
Dolor ad eiusmod, eu ea.

![[Some Document#Some Section]]

Culpa duis, ut id excepteur.
```

This will be resolved to this result:

``` markdown
Dolor ad eiusmod, eu ea.

Aliqua ea reprehenderit aliquip aliquip laborum.

Culpa duis, ut id excepteur.
```

2.  *Custom header transclusions* are placed at the end of a header. The removed header is replaced with the one in this header.

``` markdown
Dolor ad eiusmod, eu ea.

### Custom section title ![[Some Document#Some Section]]

Culpa duis, ut id excepteur.
```

This will be resolved to this result:

``` markdown
Dolor ad eiusmod, eu ea.

### Custom section title

Aliqua ea reprehenderit aliquip aliquip laborum.

Culpa duis, ut id excepteur.
```

3.  *Empty header transclusions* keep the original header of the transcluded content. They are written in a header like the custom header transclusion, but define no custom header title.

``` markdown
Dolor ad eiusmod, eu ea.

### ![[Some Document#Some Section]]

Culpa duis, ut id excepteur.
```

This will be resolved to this result:

``` markdown
Dolor ad eiusmod, eu ea.

### Some Section

Aliqua ea reprehenderit aliquip aliquip laborum.

Culpa duis, ut id excepteur.
```

> #### warning {: .warning}
>
> Intra-document transclusions, i.e., transclusions of sections inside the same document, are currently not supported due to a too coarse transclusion recursion detection. However, support for such transclusions is planned for the next version.

