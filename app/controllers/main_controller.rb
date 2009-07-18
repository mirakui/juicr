class MainController < ApplicationController
  before_filter :login_required

  def index
    @user = user_from_session
    @last_channels = Channel.find :all, :order => 'updated_at DESC', :limit => 10
  end

end
