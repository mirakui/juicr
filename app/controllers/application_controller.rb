require 'pit'
require 'oauth'

# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def oauth_filter
    pit = Pit.get('juicr_oauth')
    logger.debug 'consumer_key = ' +  pit['consumer_key'].inspect
    logger.debug 'consumer_secret = ' +  pit['consumer_secret'].inspect
    
    consumer = OAuth::Consumer.new(
      pit['consumer_key'],
      pit['consumer_secret'],
      :site => 'http://twitter.com'
    )

    request_token = consumer.get_request_token
    logger.debug "request_token = #{request_token.inspect}"
    session[:request_token] = request_token.token
    session[:request_token_secret] = request_token.secret
    callback_url = "http://loclhost:3000/main/oauth_callback"
    redirect_to request_token.authorize_url + "?oauth_callback=#{callback_url}"
    

  end
end
