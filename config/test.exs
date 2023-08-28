import Config

config :magma,
  dir: "test/data/example_vault",
  default_generation: Magma.Generation.Mock

config :openai,
  api_key: {:system, "OPENAI_API_KEY"},
  organization_key: {:system, "OPENAI_ORGANIZATION_KEY"},
  http_options: [recv_timeout: 10_000]

config :exvcr,
  vcr_cassette_library_dir: "test/cassettes/vcr",
  custom_cassette_library_dir: "test/cassettes/custom",
  filter_request_headers: ["OpenAI-Organization", "Authorization"]
