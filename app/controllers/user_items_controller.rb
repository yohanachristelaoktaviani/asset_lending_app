class UserItemsController < ApplicationController
  def index
    @user_items = Item.order('code ASC').where.not(status: "unavailable")
  end

  def show
    @user_item = Item.find(params[:id])
  end
end
