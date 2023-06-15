class AssetReturnItemsController < ApplicationController
  def index
    @return_items = AssetReturnItem.all
  end

  def show
    @return_item = AssetReturnItem.find(params[:id])
  end

  def received
    @return_item = AssetReturnItem.find(params[:id])
    @return_item.status = "received"
    @return_item.item_name.status = "available"
    @return_item.admin_id = current_user.id
    @return_item.item_name.save
    @return_item.save
    @current_user = current_user
    flash[:success] = "Received succesfully"
    redirect_to asset_return_items_path(@return_item)
  end
end
