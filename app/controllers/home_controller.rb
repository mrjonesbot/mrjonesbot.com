class HomeController < ApplicationController
  skip_before_action :protect_from_spam, raise: false

  def index
    @profile = career_context["profile"]
    @stack = ["Rails", "PostgreSQL", "Hotwire", "Solid Queue", "Stripe", "Docker", "Grafana", "Fly.io", "Claude Code"]
    @location = "Chicago, IL"
    @open_to_work = true

    @building_projects = [
      { name: "NestingBird", description: "HOA SaaS", url: "https://nestingbird.co" },
      { name: "RiseKit", description: "Workforce development platform", url: "https://risekit.co" },
      { name: "Product Heist", description: "Product discovery community", url: "https://productheist.com" }
    ]

    @open_source_projects = [
      { name: "Sage", description: "Natural language reporting Rails engine built on Blazer gem", url: "https://github.com/mrjonesbot/sage" },
      { name: "Snitch", description: "GitHub Actions monitoring for Rails", url: "https://github.com/mrjonesbot/snitch" },
      { name: "Highlite", description: "Code highlighting gem", url: "https://github.com/mrjonesbot/highlite" },
      { name: "Bureau", description: "Coming soon", url: "#" },
      { name: "Invoiceflow", description: "Coming soon", url: "#" }
    ]

    @latest_post = { title: "Why HOA boards need software, not spreadsheets", url: "#" }
  end

  private

  def career_context
    @career_context ||= YAML.load_file(Rails.root.join("config/career_context.yml"))
  end
end
