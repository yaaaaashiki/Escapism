class MailAddressesController < ApplicationController
  skip_before_action :require_login, only: [:index, :new, :create]
  before_action :exists_mail?, only: [:index]
  SUBJECT  = "【論文検索システム Escapism】 ユーザ登録ページのご案内"

  def index
  end

  def new
    @mail = MailAddress.new
  end

  def create
    @mail = MailAddress.new(address: params[:address][:name])
    if @mail.valid? && @mail.save
      send_email(params[:address][:name])
      redirect_to mail_addresses_path
    else
      render :new
    end
  end

  private

    def send_email(address)
      Admin::InviteUserMailer.invite(address, SUBJECT).deliver
    end

    def exists_mail?
      raise ActionController::RoutingError.new('here is only admin user page') unless Rails.application.routes.recognize_path(request.referrer)[:action] == "new"
    end
end
