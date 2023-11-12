import Config

config :magma, Magma.Generation.OpenAI,
  model: "gpt-4-1106-preview",
  temperature: 0.6

config :openai,
  api_key: {:system, "OPENAI_API_KEY"},
  organization_key: {:system, "OPENAI_ORGANIZATION_KEY"},
  http_options: [recv_timeout: 300_000]
