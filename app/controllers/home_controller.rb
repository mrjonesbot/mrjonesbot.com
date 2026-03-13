class HomeController < ApplicationController
  skip_before_action :protect_from_spam, raise: false

  def index
    site = Rails.application.credentials.site

    @profile = site[:profile]
    @stack = site[:stack]
    @location = site.dig(:profile, :location)
    @open_to_work = site.dig(:profile, :open_to_work)
    @building_projects = site[:building_projects]
    @open_source_projects = site[:open_source_projects]
    @also_roles = site[:also_roles]
    @self_assessment = site.dig(:career_context, :self_assessment)
  end
end
