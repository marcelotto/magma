
A set of tags which should be added on all generated documents with the `default_tags` key can be configured for your application via `config.exs`:

```elixir
config :magma,  
  default_tags: ["magma-vault"]
```

This can be useful if you want to separate them from other documents in your vault, e.g. to be able to filter them.
