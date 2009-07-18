# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def user_from_session
    case RAILS_ENV
    when 'production'
      User.find( :first, :conditions => {
        :screen_name => session[:screen_name],
        :token => session[:access_token]
      })
    when 'development'
      logger.debug 'session = '+session.inspect
      User.find( :first, :conditions => {
        :screen_name => DEBUG_SCREEN_NAME
      })
      #nil
    end
  end

  def login_required
    unless user_from_session
      session[:oauth_backuri] = request.request_uri
      redirect_to :controller => :users, :action => :create
      return
    end
  end

end
