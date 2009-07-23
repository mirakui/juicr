class MainController < ApplicationController
  before_filter :user_from_session
  before_filter :login_required

  def index
    @last_channels = Channel.find :all, :order => 'updated_at DESC', :limit => 10
  end

end
