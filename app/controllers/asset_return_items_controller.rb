class AssetReturnItemsController < ApplicationController

  before_action :authenticate_user!, except: [:main]

  def index
    @return_items = AssetReturnItem.joins(asset_return: :user).order('asset_returns.code ASC').page(params[:page]).per(1)
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"

      @return_items = AssetReturnItem.joins(asset_return: :user)
                                     .includes(:item, asset_return: :user)
                                     .joins('LEFT JOIN users admin ON admin.id = asset_return_items.admin_id')
                                     .where("lower(asset_returns.code) LIKE :search
                                              OR lower(items.name) LIKE :search
                                              OR lower(items.code) LIKE :search
                                              OR lower(asset_return_items.actual_item_condition) LIKE :search
                                              OR lower(asset_returns.return_status) LIKE :search
                                              OR lower(users.name) LIKE :search
                                              OR lower(admin.name) LIKE :search
                                              OR (asset_returns.actual_return_datetime AT time zone 'utc' AT time zone 'Asia/Jakarta')::text like :search
                                              OR lower(asset_return_items.status) LIKE :search",
                                      search: search_term)
      # binding.pry
    end
  end



  def show
    @return_item = AssetReturnItem.find(params[:id])
  end

  def received
    @return_item = AssetReturnItem.find(params[:id])
    @return_item.status = "received"
    @return_item.item.status = "available"
    @return_item.admin_id = current_user.id
    @return_item.item.save
    @return_item.save
    @current_user = current_user
    flash[:success] = "Received succesfully"
    redirect_to asset_return_items_path(@return_item)
  end

  def destroy
    @asset_return = AssetReturn.find_by(id: params[:user_asset_return_id])
    # @asset_return.asset_returns.destroy
    item = AssetReturnItem.find(params[:id])
    item.destroy
    flash[:danger] = 'Item removed successfully'
    redirect_to new_user_asset_return_path
  end

  def export_return
    @return_items = AssetReturnItem.includes(asset_return: [:user], item: [:asset_returns, :asset_return_items]).limit(100)

    respond_to do |format|
      format.csv { send_data AssetReturnItem.generate_csv(@return_items), filename: "returns-#{Date.today}.csv" }
    end
  end


end
