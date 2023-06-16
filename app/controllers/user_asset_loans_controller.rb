class UserAssetLoansController < ApplicationController
    def index 
        @loan_items = AssetLoan.where(user_id: current_user)
    end

    def new 
        @loan_item = AssetLoan.new
    end
end
