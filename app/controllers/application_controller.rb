# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :set_raven_context
  # protect_from_forgery with: :exception
  # refs: https://github.com/rails/rails/issues/24257
  # refs: https://github.com/plataformatec/devise/pull/4033/files
  protect_from_forgery prepend: true
  before_action :configure_permitted_parameters, if: :devise_controller?
  after_action :add_response_header_user_id

  rescue_from ActionController::RoutingError, ActiveRecord::RecordNotFound, with: :render_404

  protected

  def detect_device_variant
    return if params[:device] == 'pc'

    case request.user_agent
    when /iPhone|Android|Nokia|Mobile/
      request.variant = :mobile
    end
  end

  def render_404
    render file: Rails.root.join('public', '404.html'), status: 404, layout: false, content_type: 'text/html'
  end

  def check_xhr
    return if request.xhr?

    render_404
  end

  def configure_permitted_parameters
    allow_parameters = %i[email username iidxid djname grade pref]
    devise_parameter_sanitizer.permit(:sign_up, keys: allow_parameters)
    devise_parameter_sanitizer.permit(:account_update, keys: allow_parameters)
  end

  def admin_user!
    return true if current_user.admin?

    flash[:danger] = '許可されていないページです'
    redirect_to root_path
  end

  def special_user!
    return if current_user.special?

    flash[:danger] = '不正な操作です．'
    redirect_to list_log_path
  end

  def owner_user!
    return if current_user.owner?

    flash[:danger] = '許可されていないページです'
    redirect_to root_path
  end

  def member_user!
    return if current_user.member?

    flash[:danger] = '許可されていないページです'
    redirect_to root_path
  end

  def handle_unverified_request
    super
  rescue ActionController::InvalidAuthenticityToken => e
    Raven.capture_exception(e)
    flash[:danger] = 'ページの有効期限が切れています，再度お試し下さい'
    redirect_to root_path
  end

  private

  def set_raven_context
    Raven.user_context(user: current_user.attributes) if current_user
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end

  def add_response_header_user_id
    response.set_header('X-User-Id', current_user&.iidxid.to_s)
  end
end
