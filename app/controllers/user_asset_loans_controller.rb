class UserAssetLoansController < ApplicationController
  def show
    @loan_item = AssetLoan.find(params[:id])

end

def index
    @loans = AssetLoanItem.joins(:asset_loan).where(asset_loans: { user_id: current_user.id})
end

def new
    @loan_item = AssetLoan.new
   @items = Item.where(status: "available").where.not(condition: "unusable")
    @loan_item.asset_loan_items.build
end

def edit
    @loan_item = AssetLoan.find(params[:id])
    if @loan_item.asset_loan_items.all? { |item| item.loan_status == "accepted" }
        redirect_to user_asset_loan_path(@loan_item)
    else
        @items = Item.where("status = ?", "available")
        @loan_item.asset_loan_items.build

        @loan_datetime = @loan_item.loan_item_datetime.strftime("%m/%d/%Y %H:%M")
        @loan_item.loan_item_datetime = @loan_item.loan_item_datetime.strftime("%m/%d/%Y %H:%M")
        @loan_item.return_estimation_datetime = @loan_item.return_estimation_datetime.strftime("%m/%d/%Y %H:%M")

        @status = AssetLoanItem.where(asset_loan_id: params[:id]).pluck(:loan_status)
    end
end
end
