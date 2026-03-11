class ActionsController < ApplicationController
  skip_before_action :protect_from_spam, raise: false

  def close_overlay
    render layout: false
  end
end
