# frozen_string_literal: true

# this is the base controller for my application, all controllers
# inherit from here
class ApplicationController < ActionController::Base
  # Ensure User is authorized to access route using Pundit
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  after_action :verify_authorized, except: %i[index about], unless: :devise_controller?

  protect_from_forgery with: :exception

  # rubocop:disable Rails/LexicallyScopedActionFilter
  # These methods are defined on many controllers and user should be
  # authenticated prior to using them.
  before_action :authenticate_user!, only: %i[create new update edit destroy]
  # rubocop:enable Rails/LexicallyScopedActionFilter

  # TODO: logged out users don't count notifications
  before_action :notification_count

  def current_profile
    current_user&.profile
  end

  private

  def notification_count
    @notification_count = policy_scope(Notification).count
  end

  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(request.referrer || root_path)
  end
end
