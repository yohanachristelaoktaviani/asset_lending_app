class AssetLoansItemsController < ApplicationController
  def index
    @loan_items = AssetLoanItem.all
  end

  def show
    @loan_item = AssetLoanItem.find(params[:id])

  end

  def accept
    @loan_item = AssetLoanItem.find(params[:id])
    @loan_item.loan_status = "accepted"
    @loan_item.evidence = " "
    @loan_item.admin_id = current_user.id
    @loan_item.item_name.save
    @loan_item.save
    @current_user = current_user
    flash[:success] = "Accepted succesfully"
    redirect_to asset_loans_items_path(@loan_item)
  end

  def cancel
    @loan_item = AssetLoanItem.find(params[:id])
    @loan_item.loan_status = "waiting"
    @loan_item.item_name.status = "available"
    @loan_item.evidence = " "
    @loan_item.admin_id = current_user.id
    @loan_item.save
    @loan_item.item_name.save
    @current_user = current_user
    flash[:success] = "Canceled succesfully"
    redirect_to asset_loans_items_path(@loan_item)
  end


  # def decline
  #   @loan_item = AssetLoanItem.find(params[:id])
  #   @loan_item.loan_status = "decline"
  #   @loan_item.item_name.status = "available"
  #   @loan_item.save
  #   @loan_item.item_name.save
  #   # @loan_item.update(loan_status: 'declined', evidence: params[:evidence])
  #   redirect_to asset_loans_items_path, notice: 'Item declined successfully.'
  # end

  def decline
    @loan_item = AssetLoanItem.find(params[:id])
    @loan_item.evidence = params[:evidence]
    @loan_item.loan_status = "decline"
    @loan_item.item_name.status = "available"
    @loan_item.admin_id = current_user.id
    @current_user = current_user
    @loan_item.item_name.save
    if @loan_item.save
      flash[:errors] = "Item decline successfuly"
      redirect_to  asset_loans_items_path(@loan_item)
    else
      flash[:errors] = @loan_item.errors.full_messages
      redirect_to asset_loans_item_path
    end
  end

end
