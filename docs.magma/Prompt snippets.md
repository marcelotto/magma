
## Editorial notes

Text in square brackets in the following content shall be interpreted as editorial notes.


## Cover all content

IMPORTANT: Capture as many facts of the following sections as possible in your result. Feel free to reorganize and add content the make the text more coherent and fluid.

## Cover all content (alt.)

All of the following content should be captured in the produced result coherently.

## Mix task moduledoc

Since the module doc for a Mix task is a bit special (since it's show as `mix help` on the console) follow the following format 

```markdown
A Mix task for ...

[Description]

### Configuration

[Description of application configuration options]

### Command line options

- `--some-option` - description of some option (default: if applicable)
- ...

```

(The available options are specified with the `@options` module attribute. Note, that the command line option form is different, i.e. for `an_option` the command line option becomes `--an-option` (double hyphen prefix and underscores become hyphens). For boolean options the negative switch is `--no-an-option`.)