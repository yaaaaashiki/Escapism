class UsersController < ApplicationController
  skip_before_action :require_login, only: [:index, :new, :create]
  before_action :token_exists?, only:[:new]

  def index
  end
 
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @mail_address = MailAddress.find_by(mail: params[:user][:email])
    if @user.valid? && @user.save  #  && MailAddress.find_by(address: params[:user][:email])
      log_in @user
      redirect_to users_path
    else
      render :new 
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :year, :password)
    end

    def token_exists?
      redirect_to root_path unless Token.exists?(token: params[:token])
    end
end
