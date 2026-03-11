class HomeController < ApplicationController
  skip_before_action :protect_from_spam, raise: false

  def index
    @profile = career_context["profile"]
    @experiences = career_context["experiences"]
    @values = career_context["values"]
    @projects = career_context["projects"]
  end

  private

  def career_context
    @career_context ||= YAML.load_file(Rails.root.join("config/career_context.yml"))
  end
end
