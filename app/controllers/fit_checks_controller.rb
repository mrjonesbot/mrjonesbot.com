class FitChecksController < ApplicationController
  skip_before_action :protect_from_spam, raise: false
  before_action :check_rate_limit, only: [:create]

  def new
    # Renders the fit check overlay via Turbo Frame
  end

  def create
    job_description = params[:job_description].to_s.strip

    if job_description.length < 50
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "fit_check_result",
            partial: "fit_checks/error",
            locals: { message: "Please paste a full job description (at least 50 characters)." }
          )
        end
      end
      return
    end

    assessment_token = SecureRandom.hex(16)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          "fit_check_result",
          partial: "fit_checks/thinking",
          locals: { assessment_token: assessment_token }
        )
      end
    end

    GenerateFitCheckJob.perform_later(assessment_token, job_description.truncate(5000))
  end

  private

  def check_rate_limit
    cache_key = "fit_check_rate_limit:#{request.remote_ip}"
    count = Rails.cache.read(cache_key) || 0

    if count >= 5
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "fit_check_result",
            partial: "fit_checks/error",
            locals: { message: "Rate limit exceeded. Please wait a few minutes before trying again." }
          ), status: :too_many_requests
        end
      end
      return
    end

    Rails.cache.write(cache_key, count + 1, expires_in: 5.minutes)
  end
end
