class UsersController < ApplicationController
  # GET /users
  # GET /users.xml
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @users }
    end
  end

  def login
  end

  def show
    @user = User.find(params[:id])
    # Get this users favorites via OAuth
    @access_token = OAuth::AccessToken.new(UsersController.consumer, @user.token, @user.secret)
    RAILS_DEFAULT_LOGGER.error "Making OAuth request for #{@user.inspect} with #{@access_token.inspect}"
    @response = UsersController.consumer.request(:get, '/favorites.json', @access_token,
                                                 { :scheme => :query_string })
    case @response
    when Net::HTTPSuccess
      @favorites = JSON.parse(@response.body)
      respond_to do |format|
        format.html # show.html.erb
      end
    else
      RAILS_DEFAULT_LOGGER.error "Failed to get favorites via OAuth for #{@user}"
      # The user might have rejected this application. Or there was some other error during the request.
      flash[:notice] = "Authentication failed"
      redirect_to :action => :index
      return
    end
  end

  # Used throughout the controller.
  def self.consumer
    # The readkey and readsecret below are the values you get during registration
    pit = Pit.get('juicr_oauth')
    OAuth::Consumer.new(
      pit['consumer_key'],
      pit['consumer_secret'],
      :site => 'http://twitter.com')
  end

  def callback
    @request_token = OAuth::RequestToken.new(UsersController.consumer,
                                             session[:request_token],
                                             session[:request_token_secret])
    # Exchange the request token for an access token.
    @access_token = @request_token.get_access_token
    @response = UsersController.consumer.request(:get, '/account/verify_credentials.json',
                                                 @access_token, { :scheme => :query_string })
    case @response
    when Net::HTTPSuccess
      user_info = JSON.parse(@response.body)
      unless user_info['screen_name']
        flash[:notice] = "Authentication failed"
        redirect_to :action => :index
        return
      end

      @user = User.find( :first, :conditions => {:screen_name => user_info['screen_name']} )
      if @user
        @user.token = @access_token.token
        @user.secret = @access_token.secret
      else
        # We have an authorized user, save the information to the database.
        @user = User.new({ :screen_name => user_info['screen_name'],
                         :token => @access_token.token,
                         :secret => @access_token.secret })
      end
      @user.save!

      session[:screen_name] = user_info['screen_name']
      session[:access_token] = @access_token.token

      flash[:notice] = "Authentication successed"
      # Redirect to the show page
      # redirect_to :controller => :main, :action => :index
      logger.debug 'backuri: ' + session[:oauth_backuri]
      redirect_to session[:oauth_backuri]
    else
      RAILS_DEFAULT_LOGGER.error "Failed to get user info via OAuth"
      # The user might have rejected this application. Or there was some other error during the request.
      flash[:notice] = "Authentication failed"
      redirect_to :controller => :main, :action => :index
      return
    end
  end


  def create
    @request_token = UsersController.consumer.get_request_token
    session[:request_token] = @request_token.token
    session[:request_token_secret] = @request_token.secret
    logger.debug 'request_uri = ' + request.request_uri.inspect
    # Send to twitter.com to authorize
    redirect_to @request_token.authorize_url
    return
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.xml  { head :ok }
    end
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

end
