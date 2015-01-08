class CategoriesController < ApplicationController
  before_filter :get_category, except: [:index]

  def index
    @categories = Category.all
  end

  def create
    current_user.my_categories.create category_id: @category

    render json: {erors: []}
  end

  def destroy
    p @category
    current_user.my_categories.find_by_category_id(@category).destroy

    render json: {erors: []}
  end

  def get_category
    @category = Category.find_by_name(params.require(:name)).id
  end
end
