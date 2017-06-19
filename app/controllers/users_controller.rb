class UsersController < ApplicationController
  skip_before_action :require_login, only: [:index, :new, :create]
  before_action :token_exists?, only:[:new]

  def index
  end
 
  def new
    @user = User.new
    mail_address_id = Token.find_by(token: params[:token]).mail_address_id
    session[:email] = MailAddress.find(mail_address_id).address
  end

  def create
    @user = User.new(user_params)
    if @user.valid? && @user.save  #  && MailAddress.find_by(address: params[:user][:email])
      log_in @user
      redirect_to users_path
    else
      render :new 
    end
  end

  private
    def user_params
      params.require(:user).permit(:username, :year, :email, :password)
    end

    def token_exists?
      redirect_to root_path unless Token.exists?(token: params[:token])
    end
end
