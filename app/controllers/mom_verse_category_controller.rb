class MomVerseCategoryController < ::ApplicationController

  def index
    categories = Category.where(parent_category_id: nil)
    categories = (ActiveModel::ArraySerializer.new(categories, each_serializer: MomVerseCategorySerializer).as_json)
    render json: {categories: categories}
  end

  def topics_list
    categories = Category.where(parent_category_id: params[:category_id])
    categories ||= Category.where.not(parent_category_id: nil)
    categories = (ActiveModel::ArraySerializer.new(categories, each_serializer: MomVerseCategorySerializer).as_json)
    render json: {categories: categories}
  end

  def search
    params.require(:term)

    discourse_expires_in 1.minute

    search_args = { guardian: guardian }
    search_args[:search_type] = :header
    search_args[:user_id] = current_user.id if current_user.present?
    search_args[:type_filter] = params[:type_filter] if params[:type_filter].present?
    search_args[:search_for_id] = true if params[:search_for_id].present?
    search_args[:ip_address] = request.remote_ip
    search_args[:user_agent] = request.user_agent

    search = Search.new(params[:term], search_args)
    result = search.execute(readonly_mode: @readonly_mode)
    render_serialized(result, MomVerseSearchResultSerializer, result: result)
  end

  private

  def user_params
    params.permit(:date_of_birth, :name, :username, :password)
  end
end
