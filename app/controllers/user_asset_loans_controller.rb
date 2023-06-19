class UserAssetLoansController < ApplicationController
    def index
        @loan_items =  @loan_items = AssetLoanItem.joins(:asset_loan).where(asset_loans: { user_id: current_user.id}) 
    end
    
    def new 
        @loan_item = AssetLoan.new
        @items = Item.where("status = ?", "available") 
    end

    def create 
        @loan_item = AssetLoan.new(user_asset_loan_params)
        @loan_item.user_id = current_user.id
         if @loan_item.save
            flash[:success] = "Accepted succesfully"
            redirect_to user_asset_loans_path
         end
    end

    private 

    def user_asset_loan_params 
        params.require(:asset_loan).permit(:code, :user_id, :loan_item_datetime, :estimation_return_datetime, :necessary)
    end
end
