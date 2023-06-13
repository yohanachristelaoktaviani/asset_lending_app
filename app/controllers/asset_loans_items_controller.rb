class AssetLoansItemsController < ApplicationController
  def index
    @loan_items = AssetLoanItem.all
  end

  def show
    @loan_item = AssetLoanItem.find(params[:id])

  end

  def accept
    @loan_item = AssetLoanItem.find(params[:id])

    # @user = User.all

    # binding.pry
    @loan_item.loan_status = "accepted"

    # @loan_item.item_name.status = "unavailable"
    @loan_item.admin_id = current_user.id
    # binding.pry
    @loan_item.asset_loan.save
    @loan_item.item_name.save
    @loan_item.save
    @current_user = current_user
    # @loan_item.update(@loan_item.asset_loan.loan_status = "accepted")
    # current_user.email
    redirect_to asset_loans_items_path(@loan_item)
  end

  def cancel
    @loan_item = AssetLoanItem.find(params[:id])
    @loan_item.loan_status = "cancel"
    @loan_item.item_name.status = "available"
    @loan_item.save
    @loan_item.item_name.save
    redirect_to asset_loans_items_path(@loan_item)
  end


  def decline
    @loan_item = AssetLoanItem.find(params[:id])
    @loan_item.loan_status = "decline"
    @loan_item.item_name.status = "available"
    @loan_item.save
    @loan_item.item_name.save
    redirect_to asset_loans_items_path(@loan_item)
  end

end
