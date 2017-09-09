class Admin::ThesesController < AdminController
  skip_before_action :require_login, only: [:index, :show, :update]
  before_action :set_thesis, only: [:show, :update]

  def index 
    @theses = Thesis.all
  end

  def show
  end

  def update
    if @thesis.update(thesis_params)
      redirect_to admin_theses_url
    else
      render :show, status: :bad_request
    end
  end

  private
    def set_thesis
      @thesis = Thesis.find(params[:id])
    end

    def thesis_params
      params.require(:thesis).permit(:title, :year, :labo_id, :author_id)
    end
end

