class AssetLoansController < ApplicationController
  def create
    @loan_item = AssetLoan.new(asset_loan_params)
    # @loan_item.user_id = current_user.id
    formatted_loan_datetime = DateTime.strptime(asset_loan_params["loan_item_datetime"], "%Y-%m-%d %H:%M")
    @loan_item.loan_item_datetime =  formatted_loan_datetime.strftime("%Y-%m-%dT%H:%M")
    formatted_return_datetime = DateTime.strptime(asset_loan_params["return_estimation_datetime"], "%Y-%m-%d %H:%M")
    @loan_item.return_estimation_datetime = formatted_return_datetime.strftime("%Y-%m-%dT%H:%M")

    if @current_user.role == "admin"
    selected_user_id = asset_loan_params[:user_id]
    @loan_item.user_id = selected_user_id
    else
    @loan_item.user_id = @current_user.id
    end

    if @loan_item.save
      flash[:success] = "Loan request accepted successfully"
      if @current_user.role == "admin"
        redirect_to asset_loans_items_path
      else
        redirect_to user_asset_loans_path
      end
    else
      flash[:errors] = @loan_item.errors.full_messages
      redirect_to new_user_asset_loan_path
    end
  end

  def update
    @loan_item = AssetLoan.find(params[:id])
    formatted_return_datetime = DateTime.strptime(asset_loan_params["return_estimation_datetime"], "%m/%d/%Y %H:%M")
    ActiveRecord::Base.transaction do
      @loan_item.asset_loan_items.destroy_all
      @loan_item.attributes = asset_loan_params
      @loan_item.return_estimation_datetime = formatted_return_datetime.strftime("%Y-%m-%dT%H:%M")
      if @loan_item.save
        flash[:success] = "Loan request updated successfully"
        redirect_to user_asset_loans_path
      else
        flash[:errors] = @loan_item.errors.full_messages
        redirect_to edit_user_asset_loan_path(@loan_item.id)
        raise ActiveRecord::Rollback
      end
    end
  end

  def destroy
    @loan_item = AssetLoan.find(params[:id])
    if @loan_item.destroy
      flash[:success] = "Loan code was successfully deleted"
      redirect_to user_asset_loans_path
    else
      puts 'ERROR ', @loan_item.errors.full_messages
      flash[:errors] = @loan_item.errors.full_messages
      redirect_to user_asset_loans_path
    end
  end

  private

  def asset_loan_params
      params.require(:asset_loan).permit(:code, :user_id, :loan_item_datetime, :return_estimation_datetime, :necessary, asset_loan_items_attributes: [:asset_loan_id, :item_id, :loan_status, :admin_id, :_destroy])
  end
end
