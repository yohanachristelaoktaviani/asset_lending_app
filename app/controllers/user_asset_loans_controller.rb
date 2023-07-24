class UserAssetLoansController < ApplicationController
  def show
    @loan_item = AssetLoan.find(params[:id])

end

def index
    @loans = AssetLoanItem.joins(:asset_loan).where(asset_loans: { user_id: current_user.id}).page(params[:page]).per(4)

    if params[:search].present?
        search_term = "%#{params[:search].downcase}%"

        @loans = AssetLoanItem.joins(asset_loan: :user)
                                   .includes(:item, asset_loan: :user)
                                   .joins('LEFT JOIN users admin ON admin.id = asset_loan_items.admin_id')
                                  #  Left join -> menghubungkan table dan menampilkan semua data yg terdapat di kiri table, data yg kosong akan bernilai NULL
                                  .where("lower(asset_loans.code) LIKE :search OR lower(items.name) LIKE :search
                                   OR (asset_loans.loan_item_datetime AT time zone 'utc' AT time zone 'Asia/Jakarta')::text LIKE :search
                                   OR (asset_loans.return_estimation_datetime AT time zone 'utc' AT time zone 'Asia/Jakarta')::text LIKE :search
                                   OR lower(asset_loans.necessary) LIKE :search
                                   OR lower(asset_loans.loan_status) LIKE :search", search: "%#{params[:search].downcase}%")
    end
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
