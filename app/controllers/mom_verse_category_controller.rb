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

  private

  def user_params
    params.permit(:date_of_birth, :name, :username, :password)
  end
end
