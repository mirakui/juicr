class ChannelsController < ApplicationController
  before_filter :login_required, :only => [:new, :create]

  # GET /channels
  # GET /channels.xml
  def index
    @channels = Channel.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @channels }
    end
  end

  # GET /channels/1
  # GET /channels/1.xml
  def show
    # @channel = Channel.find(params[:id])
    if params[:id]
      @channel = Channel.find(params[:id])
    elsif params[:alias]
      @channel = Channel.find(:first, :conditions => {:alias => params[:alias]})
    end
    @page = params[:page] ? params[:page].to_i : 1
    @rpp  = params[:rpp]  ? params[:rpp].to_i  : 100

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @channel }
    end
  end

  # GET /channels/new
  # GET /channels/new.xml
  def new
    @channel = Channel.new
    @channel.author = user_from_session

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @channel }
    end
  end

  # GET /channels/1/edit
  def edit
    @channel = Channel.find(params[:id])
    @channel.extract_users = @channel.extract_users.tr("\001","\n")
    @channel.alias[/^#{@channel.author.screen_name}_/]=''
  end

  # POST /channels
  # POST /channels.xml
  def create
    @channel = Channel.new(params[:channel])
    @channel.alias.insert(0, "#{@channel.author.screen_name}_")

    respond_to do |format|
      if @channel.save
        flash[:notice] = 'Channel was successfully created.'
        format.html { redirect_to( :alias => @channel.alias, :action => :show ) }
        format.xml  { render :xml => @channel, :status => :created, :location => @channel }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @channel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /channels/1
  # PUT /channels/1.xml
  def update
    @channel = Channel.find(params[:id])
    params[:channel][:alias].insert(0, "#{@channel.author.screen_name}_")

    respond_to do |format|
      if @channel.update_attributes(params[:channel])
        flash[:notice] = 'Channel was successfully updated.'
        format.html { redirect_to( :alias => @channel.alias, :action => :show ) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @channel.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /channels/1
  # DELETE /channels/1.xml
  def destroy
    @channel = Channel.find(params[:id])
    @channel.destroy

    respond_to do |format|
      format.html { redirect_to(channels_url) }
      format.xml  { head :ok }
    end
  end

  def validate_alias
    render :update do |page|
      # TODO call the model's validation method
      #
      if Channel.exists?( :alias => params[:alias] )
        page.replace_html( :validate_alias_result, params[:alias] + ': already exists' )
      else
        page.replace_html( :validate_alias_result, params[:alias] + ': OK' )
      end

    end
  end
end
