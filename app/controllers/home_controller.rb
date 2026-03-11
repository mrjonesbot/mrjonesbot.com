class HomeController < ApplicationController
  skip_before_action :protect_from_spam, raise: false

  def index
    @profile = career_context["profile"]
    @stack = ["Rails", "PostgreSQL", "Hotwire", "Solid Queue", "Stripe", "Fly.io", "Claude Code"]
    @location = "Chicago, IL"
    @open_to_work = true
    @building = { name: "NestingBird", description: "HOA SaaS" }
    @latest_post = { title: "Why HOA boards need software, not spreadsheets", url: "#" }
    @open_source = career_context["projects"].first
  end

  private

  def career_context
    @career_context ||= YAML.load_file(Rails.root.join("config/career_context.yml"))
  end
end
