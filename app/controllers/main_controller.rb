class MainController < ApplicationController
  before_filter :login_required

  def index
    @user = user_from_session
  end

end
