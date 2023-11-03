# Magma-Transclusion-Resolution

## TODO

- Unterschiede zu Header transclusion gegenüber inline transclusion mit eigenem Header davor: 
	- Ignorieren des gesamten Abschnitt falls leer

## Description

Transclusion resolution is in Magma the process of resolving an Obsidian transclusion by replacing it with its content.  This is the basis in Magma for the composition of LLM prompts, which are defined as compositions of transclusions, which will be resolved before the execution on an LLM. However, the content of the referenced document or document section is not inserted unchanged, but the following processing steps are applied beforehand:

- Comments (`<!-- comment -->`) are removed.
- Internal links are replaced with the target as plain text (or their display text when given).
- Transclusions within the transcluded content itself are resolved recursively (unless it would result in an infinite recursion)
- If the transcluded content (after removing the comments), consists exclusively of a heading with no content below it, the transclusion is resolved with the empty string, i.e. the empty section is NOT inserted.
- The level of the transcluded sections is adjusted according to the current level at the point of the transclusion.

There are three kinds of transclusions which are resolved slightly different, mostly with respect to how they handle the leading header of the transcluded content:

- *Inline transclusions*: remove the leading header
- *Custom header transclusions*: replace the leading header
- *Empty header transclusions*: keep the leading header

Another difference between these transclusion resolution types is how they handle the prologue, i.e. text before the document title, on complete document transclusion resolutions:

- both kinds of header transclusions omit prologue
- inline transclusions keep the prologue which has the consequence that there is no leading section title to omit in this case, i.e. the document title section becomes a subsection

As for prologue handling for document transclusions: for [[Magma.Document]]s, these are generally ignored, as it is for document controls by definition.

On document transclusions with multiple top-level sections the other top-level sections are shifted one level, so they become subsections of the first top-level section, so that their context in the transcluding document is clear.

## Compact Description

Transclusion resolution is in Magma the process of resolving an Obsidian transclusion by replacing it with its content.  This is the basis in Magma for the composition of LLM prompts, which are defined as compositions of transclusions, which will be resolved before the execution on an LLM. However, the content of the referenced document or document section is not inserted unchanged, but the following processing steps are applied beforehand:

- Comments (`<!-- comment -->`) are removed.
- Internal links are replaced with the target as plain text (or their display text when given)
- Transclusions within the transcluded content itself are resolved recursively (unless it would result in an infinite recursion)
- If the transcluded content (after removing the comments), consists exclusively of a heading with no content below it, the transclusion is resolved with the empty string, i.e. the empty section is NOT inserted.
- The level of the transcluded sections is adjusted according to the current level at the point of the transclusion.

There are three kinds of transclusions which are resolved slightly different, mostly with respect to how they handle the leading header of the transcluded content:

- *Inline transclusions*: remove the leading header
- *Custom header transclusions*: replace the leading header
- *Empty header transclusions*: keep the leading header

## Description with examples

Transclusion resolution is in Magma the process of resolving an Obsidian transclusion (eg. `![[Some document]]`) by replacing it with its content.  This is the basis in Magma for the composition of LLM prompts, which are defined as compositions of transclusions, which will be resolved before the execution on an LLM. However, the content of the referenced document or document section is not inserted unchanged, but the following processing steps are applied beforehand:

- Comments (`<!-- comment -->`) are removed.
- Internal links are replaced with the target (or their display text when available) as plain text.
- Transclusions within the transcluded content itself are resolved recursively (unless it would result in an infinite recursion)
- If the transcluded content (after removing the comments), consists exclusively of a heading with no content below it, the transclusion is resolved with the empty string, i.e. the empty section is NOT inserted.
- The level of the transcluded sections is adjusted according to the current level at the point of the transclusion.

There are three kinds of transclusions which are resolved slightly different, mostly with respect to how they handle the leading header of the transcluded content:

- *Inline transclusions*: remove the leading header
- *Custom header transclusions*: replace the leading header
- *Empty header transclusions*: keep the leading header

Another difference between these transclusion resolution types is how they handle the prologue, i.e. text before the document title, on complete document transclusion resolutions:

- both kinds of header transclusions omit prologue
- inline transclusions keep the prologue which has the consequence that there is no leading section title to omit in this case, i.e. the document title section becomes a subsection

As for prologue handling for document transclusions: for [[Magma.Document]]s, these are generally ignored, as it is for document controls by definition.

On document transclusions with multiple top-level sections the other top-level sections are shifted one level, so they become subsections of the first top-level section, so that their context in the transcluding document is clear.

<!--
Replace this duplication with a relative transclusion when supported:
![[#Description]]
-->

Let's say for example, we have the following document to demonstrate these differences:

```markdown
Some text before the document title like this, is called prologue in Magma.

# Some document

Id occaecat fugiat ea anim adipiscing.

## Some Section

Aliqua ea reprehenderit aliquip aliquip laborum.

```


1. *Inline transclusions* in the body of a section, which stand alone in their own paragraph:

```markdown
Dolor ad eiusmod, eu ea.

![[Some Document#Some Section]]

Culpa duis, ut id excepteur.
```

This will be resolved to this result:

```markdown
Dolor ad eiusmod, eu ea.

Aliqua ea reprehenderit aliquip aliquip laborum.

Culpa duis, ut id excepteur.
```

2. *Custom header transclusions* are placed at the end of a header. In this case the removed header is replaced with the one in this header (except for the transclusion itself of course). 

```markdown
Dolor ad eiusmod, eu ea.

### Custom section title ![[Some Document#Some Section]]

Culpa duis, ut id excepteur.
```

This will be resolved to this result:

```markdown
Dolor ad eiusmod, eu ea.

### Custom section title

Aliqua ea reprehenderit aliquip aliquip laborum.

Culpa duis, ut id excepteur.
```

3. *Empty header transclusions* finally are the above mentioned exception, which keep the original header of the transcluded content. The are written are in header like the custom header transclusion, but define no custom header title, i.e. consit solely of the transclusion.

```markdown
Dolor ad eiusmod, eu ea.

### ![[Some Document#Some Section]]

Culpa duis, ut id excepteur.
```

This will be resolved to this result:

```markdown
Dolor ad eiusmod, eu ea.

### Some Section

Aliqua ea reprehenderit aliquip aliquip laborum.

Culpa duis, ut id excepteur.
```



## Usage patterns

### Optional longer descriptions with local transclusions

Sometimes we want to offer a more extensive description, e.g. with more examples as an alternative description, which we want to offer as an alternative that can be used if needed, but not by default since it would cost to much unnecessary tokens. This can be achieved with transclusion resolution of local sections like this:

```markdown
# Something

## Description

Description of the basics


## Description with examples

![[#Description]]

Extensive examples ...

```

## Problems

### Obsidian-Magma transclusion presentation mismatch problem

Unfortunately, the different types of transclusion are not visible in Obsidian, since the first heading is always displayed there, which can become confusing, especially with nested transclusions. 