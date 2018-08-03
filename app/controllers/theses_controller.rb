class ThesesController < ApplicationController
  before_action :init_set_popular_theses
  before_action :init_flash_alert, only: [:index]
  NOT_EXIST_THESES = 0

  def index
    if check_size_index(params)
      render_414
      return
    end

    @labo_id = params[:l]
    query = params[:q]
    @search_field = params[:f]
    if params[:f] && params_invalid?(params[:f])
      render_404
      return
    end
   
    if search_theses?(query, @labo_id, @search_field)
      @theses = Thesis.search_by_keyword(query, @labo_id, @search_field).page(params[:page]).per(4)
      if not_exist_theses(@theses)
        flash[:alert] = 'Matching theses was not found. Try again.'
      end
    end

    @labos = Labo.all
  end

  def show
    if check_size_show(params)
      render_414
      return
    end

    @thesis = Thesis.find(params[:id])
    if @thesis
      impressionist(@thesis)
      if @thesis.impressionist_count.nil?
        @thesis.update_attribute(:access, 0)
      else
        @thesis.update_attribute(:access, @thesis.impressionist_count(:filter=>:all))
      end

      @theses = Thesis.more_like_this(@thesis.id).page(params[:page]).per(4)
      @author = Author.all
    else
      logger.error("Internal server error: ThesesController show action 20 lines: @theses is undefined")
      render_500
      return
    end

    @labos = Labo.all
  end

  def download
    if invalid_size?(params[:id])
      render_414
      return
    end

    thesis = Thesis.find(params[:id])
    if thesis.nil?
      logger.error("Internal server error: ThesesController show action 20 lines: @theses is undefined")
      render_500
      return
    end
    send_file(thesis.url, disposition: :inline)
  end

  private
    def init_flash_alert
      flash[:alert] = nil
    end

    def init_set_popular_theses
      @popular_theses = Thesis.connection.select_all('select T1.id, T1.access, T1.title, authors.name as author_name, labos.name as labo_name
                                                      from (
                                                        select *
                                                        from theses
                                                        order by access desc
                                                        limit 5
                                                      ) T1 inner join authors on (
                                                        T1.author_id = authors.id
                                                      ) inner join labos on (
                                                        T1.labo_id = labos.id
                                                      )')
    end

    def search_theses?(query, labo_id, field)
      query.present? || (labo_id.present? && labo_id.to_i != Labo.NO_LABO_ID) || field.present?
    end

    def not_exist_theses(theses)
      theses.size == NOT_EXIST_THESES
    end

    def check_size_index(params)
      invalid_size?(params[:q]) || invalid_size?(params[:l]) || invalid_size?(params[:f])
    end

    def check_size_show(params)
      invalid_size?(params[:id]) || invalid_size?(params[:page])
    end

    def params_invalid?(search_field)
      search_field != Thesis.SEARCH_BY_BODY && search_field != Thesis.SEARCH_BY_TITLE
    end
end
