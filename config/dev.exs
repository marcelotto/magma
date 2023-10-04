import Config

config :magma, Magma.Generation.OpenAI,
  model: "gpt-4",
  temperature: 0.2

config :openai,
  api_key: {:system, "OPENAI_API_KEY"},
  organization_key: {:system, "OPENAI_ORGANIZATION_KEY"},
  http_options: [recv_timeout: 60_000]
