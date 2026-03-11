RubyLLM.configure do |config|
  config.anthropic_api_key = ENV["ANTHROPIC_API_KEY"] || Rails.application.credentials.dig(:anthropic, :api_key)
  config.default_model = "claude-haiku-4-5-20251001"

  # Use the new association-based acts_as API (recommended)
  config.use_new_acts_as = true
end
