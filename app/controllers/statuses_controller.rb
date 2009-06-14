class StatusesController < ApplicationController
  def update
    author = user_from_session

    access_token = OAuth::AccessToken.new(UsersController.consumer, author.token, author.secret)

    logger.debug "Making OAuth request for #{author.inspect} with #{access_token.inspect}"
    status_text = params[:status][:text]
    logger.debug "text = '#{status_text}'"
    if !status_text || status_text.length == 0
      render :json => {:error => 'the status was empty'}, :status => 400
      return
    end

    response = access_token.post '/statuses/update.json', {:status => status_text}

    case response
    when Net::HTTPSuccess
      logger.debug response.inspect
      render :json => JSON.parse(response.body)#, :code => response.code
    else
      render :json => {:error => "Twitter API Error(#{response.code})"}, :status => response.code
    end
  end

end
