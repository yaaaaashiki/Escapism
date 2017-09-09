class Admin::SessionsController < AdminController
  skip_before_action :authenticate_admin_user!

  def new
  end

  def create
    @admin_user = AdminUser.find_by(username: params[:username])
    if @admin_user && @admin_user.authenticate(params[:password])
      admin_log_in @admin_user
      redirect_to admin_url, notice: 'login succeed'
    else
      flash.now[:warning] = 'login failed'
      render :new, status: :unauthorized
    end
  end

  def destroy
    admin_log_out
    redirect_to admin_sign_in_url, notice: 'Success logout'
  end
end
