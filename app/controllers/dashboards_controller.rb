class DashboardsController < ApplicationController

  before_action :authenticate_user!, except: [:main]


  def index
    @loan_items = AssetLoanItem
                  .joins(asset_loan: :user)
                  .joins("LEFT JOIN asset_returns ON asset_loan_items.asset_loan_id = asset_returns.asset_loan_id")
                  .joins("LEFT JOIN asset_return_items ON asset_returns.id = asset_return_items.asset_return_id")
                  .where(loan_status: "accepted")
                  .where("asset_return_items.status IS NULL")
                  .select("asset_loan_items.*, asset_return_items.status")
                  .order('asset_loans.code DESC')
                  # .where.not("asset_return_items.status = ?", "received")
                  .page(params[:page])
                  .per(5)
    @return_items = AssetReturnItem
                    .joins(asset_return: :user)
                    .order('asset_returns.return_status DESC, asset_returns.actual_return_datetime DESC')
                    .page(params[:page])
                    .per(5)
    @items = Item
            .where(selected_item: "true")
            .where(status: "available")
            .order('code ASC')
            .page(params[:page])
            .per(5)

    @return_and_loan = AssetReturnItem
            .joins(asset_return: :user)
            .order('asset_returns.return_status ASC, asset_returns.actual_return_datetime ASC')
            .page(params[:page])
            .per(5)
  end
end
