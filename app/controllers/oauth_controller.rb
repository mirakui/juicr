class OauthController < ApplicationController

  def login
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
    redirect_to request_token.authorize_url
  end

end
