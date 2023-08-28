import Config

config :openai,
  api_key: {:system, "OPENAI_API_KEY"},
  organization_key: {:system, "OPENAI_ORGANIZATION_KEY"},
  http_options: [recv_timeout: 60_000]
