import Config

config :magma,
  default_tags: ["magma-vault"]

import_config "#{Mix.env()}.exs"
