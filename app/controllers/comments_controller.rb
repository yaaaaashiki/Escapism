class CommentsController < ApplicationController
  MAX_LINES = 10

  def create
    if invalid_size?(params[:thesis_id])
      render_414
      return
    end

    @thesis = Thesis.find(params[:thesis_id])
    if @thesis.nil?
      logger.error("Internal server error: CommentsController create action 3 lines: @theses is undefined")
      render_500
      return
    end

    if invalid?(comment_params[:body])
      redirect_to thesis_path(@thesis)
      return
    end

    @comment = @thesis.comments.create(body: comment_params[:body], user_id: session[:user_id])
    redirect_to thesis_path(@thesis)
  end
  
  private
    def comment_params
      params.require(:comment).permit(:body)
    end

    def invalid?(comment)
      if comment.scan(/\R/).size > MAX_LINES || comment.strip.blank?
        return true
      end
      return false
    end
end
