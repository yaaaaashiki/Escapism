class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  include SessionsHelper
  protect_from_forgery with: :exception
  before_action :require_login
#  rescue_from ActiveRecord::RecordNotFound, with: :render_404
#  rescue_from ActionController::RoutingError, with: :render_404
#  rescue_from Exception, with: :render_500

  def render_404
    render file: Rails.root.join('public/404.html.erb'), status: 404, layout: 'application', content_type: 'text/html'
  end

  def render_500
    render file: Rails.root.join('public/500.html.erb'), status: 500, layout: 'application', content_type: 'text/html'
  end

  private
   
  def not_authenticated
    redirect_to login_path, alert: "Please login first"
  end
end
