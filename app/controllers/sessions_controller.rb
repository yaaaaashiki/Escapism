class SessionsController < ApplicationController
  skip_before_action :require_login, except: [:destroy]
  
  def new
    @user = User.new
  end
 
  def create
    if @user = login(StringUtil.to_half_width_lowercase(params[:session][:email]), params[:session][:password])
      redirect_back_or_to(theses_url)
    else
      flash.now[:alert] = 'ログインに失敗しました。もう一度入力してください'
      render :new, status: :unauthorized
    end
  end
 
  def destroy
    logout
    redirect_to root_url 
  end
end
