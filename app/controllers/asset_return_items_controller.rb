class AssetReturnItemsController < ApplicationController

  require 'active_support/time'

  before_action :authenticate_user!, except: [:main]
  before_action :authenticate_admin!

  def index
    @return_items = AssetReturnItem.joins(asset_return: :user).order('asset_returns.code DESC')
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"

      @return_items = @return_items.joins(asset_return: :user)
                                     .includes(:item, asset_return: :user)
                                     .joins('LEFT JOIN users admin ON admin.id = asset_return_items.admin_id')
                                     .joins('LEFT JOIN items ON items.id = asset_return_items.item_id')
                                     .where("lower(asset_returns.code) LIKE :search
                                              OR lower(items.name) LIKE :search
                                              OR lower(items.code) LIKE :search
                                              OR lower(asset_return_items.actual_item_condition) LIKE :search
                                              OR lower(asset_returns.return_status) LIKE :search
                                              OR lower(users.name) LIKE :search
                                              OR lower(admin.name) LIKE :search
                                              OR (asset_returns.actual_return_datetime AT time zone 'utc' AT time zone 'Asia/Jakarta')::text LIKE :search
                                              OR lower(asset_return_items.status) LIKE :search", search: search_term)
      # binding.pry
    end
    @return_items = @return_items.page(params[:page]).per(10)
  end




  def show
    @return_item = AssetReturnItem.find(params[:id])
    @admins = User.admins
  end

  def received
    @return_item = AssetReturnItem.find(params[:id])
    @return_item.status = "received"
    @return_item.item.status = "available"
    @return_item.admin_id = params[:name] if params[:name].present?
    @return_item.actual_item_condition = params[:condition] if params[:condition].present?
    @return_item.item.condition = @return_item.actual_item_condition
    @return_item.item.save
    @return_item.save
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
    @return_items = AssetReturnItem.includes(asset_return: [:user], item: [:asset_returns, :asset_return_items])

    session[:csv_filename] = "returns-#{Date.today}"

    respond_to do |format|
      format.csv { send_data AssetReturnItem.generate_csv(@return_items), filename: "#{session[:csv_filename]}.csv" }
    end
  end

  def authenticate_admin!
    redirect_to dashboards_path unless current_user.role == "admin"
  end


end
