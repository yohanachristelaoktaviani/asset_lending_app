class UserAssetLoansController < ApplicationController

# before_action :authenticate_admin!, only: [:new, :create]

def show
    @loan_item = AssetLoan.find(params[:id])
    @is_returned = AssetReturn.find_by(asset_loan_id: params[:id])
end

def index
    @loan_items = AssetLoanItem.joins(:asset_loan).where(asset_loans: { user_id: current_user.id})

    if params[:search].present?
        search_term = params[:search].split(/[^\w,: ]+/)
        datetime_string = search_term.find { |term| term.match?(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/) }
        if datetime_string.present?
            datetime = DateTime.parse(datetime_string)
            @loan_items = @loan_items.where("asset_loans.loan_item_datetime = :datetime", datetime: datetime)
        else
            search_query = "%#{params[:search].downcase}%"
            @loan_items = @loan_items.joins(asset_loan: :user)
                                        .includes(:item, asset_loan: :user)
                                        .joins('LEFT JOIN users admin ON admin.id = asset_loan_items.admin_id')
                                        .joins('LEFT JOIN items ON items.id = asset_loan_items.item_id')
                                        #  Left join -> menghubungkan table dan menampilkan semua data yg terdapat di kiri table, data yg kosong akan bernilai NULL
                                        .where("lower(asset_loans.code) LIKE :search OR lower(items.name) LIKE :search
                                        OR lower(asset_loan_items.loan_status) LIKE :search
                                        OR lower(items.condition) LIKE :search
                                        OR lower(admin.name) LIKE :search
                                        OR (asset_loans.loan_item_datetime AT time zone 'utc' AT time zone 'Asia/Jakarta')::text LIKE :search
                                        OR (asset_loans.return_estimation_datetime AT time zone 'utc' AT time zone 'Asia/Jakarta')::text LIKE :search
                                        OR lower(asset_loans.necessary) LIKE :search", search: search_query)
        end
    end
    @loan_items = @loan_items.page(params[:page]).per(10).order('asset_loans.code DESC')
end

def new
    @loan_item = AssetLoan.new
    @users = User.all
    @current_user = current_user
    @items = Item.where(status: "available").where.not(condition: "tidak layak pakai")
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

# private

# def authenticate_admin!
#   redirect_to root_path unless current_user.role == "admin"
# end