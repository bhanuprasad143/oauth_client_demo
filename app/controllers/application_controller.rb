class ApplicationController < ActionController::Base
  protect_from_forgery

  def login_required
    authenticate_user!
  end
end

