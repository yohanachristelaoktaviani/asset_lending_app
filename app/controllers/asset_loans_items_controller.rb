class AssetLoansItemsController < ApplicationController

  before_action :authenticate_user!, except: [:main]

  def index
    @loan_items = AssetLoanItem.joins(asset_loan: :user).order('asset_loans.code ASC').page(params[:page]).per(2)
    if params[:search].present?
      search_terms = params[:search].split(/[^\w,: ]+/)

      datetime_string = search_terms.find { |term| term.match?(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/) }

      # binding.pry
      if datetime_string.present?
        datetime = DateTime.parse(datetime_string)

        @loan_items = @loan_items.where("asset_loans.loan_item_datetime = :datetime", datetime: datetime)
      else
        search_query = "%#{params[:search].downcase}%"
        # binding.pry
        @loan_items = AssetLoanItem.joins(asset_loan: :user)
                                 .includes(:item, asset_loan: :user)
                                 .joins('LEFT JOIN users admin ON admin.id = asset_loan_items.admin_id')
                                #  Left join -> menghubungkan table dan menampilkan semua data yg terdapat di kiri table, data yg kosong akan bernilai NULL
                                  .where("lower(asset_loans.code) LIKE :search OR lower(items.name) LIKE :search OR lower(items.code) LIKE :search OR lower(items.condition)
                                  LIKE :search OR lower(asset_loans.necessary) LIKE :search OR lower(asset_loan_items.loan_status) LIKE :search OR lower(asset_loan_items.evidence)
                                  LIKE :search OR lower(users.name) LIKE :search OR lower(admin.name) LIKE :search OR (asset_loans.loan_item_datetime AT time zone 'utc' AT time zone 'Asia/Jakarta')::text
                                  LIKE :search OR (asset_loans.return_estimation_datetime AT time zone 'utc' AT time zone 'Asia/Jakarta')::text LIKE :search", search: search_query)

      end
    end
  end



  def show
    @loan_item = AssetLoanItem.find(params[:id])

  end

  def accept
    @loan_item = AssetLoanItem.find(params[:id])
    @loan_item.loan_status = "accepted"
    @loan_item.evidence = " "
    @loan_item.admin_id = current_user.id
    @loan_item.item.save
    @loan_item.save
    @current_user = current_user
    flash[:success] = "Accepted succesfully"
    redirect_to asset_loans_items_path(@loan_item)
  end

  def cancel
    @loan_item = AssetLoanItem.find(params[:id])
    @loan_item.loan_status = "waiting"
    @loan_item.item.status = "available"
    @loan_item.evidence = " "
    @loan_item.admin_id = current_user.id
    @loan_item.save
    @loan_item.item.save
    @current_user = current_user
    flash[:success] = "Canceled succesfully"
    redirect_to asset_loans_items_path(@loan_item)
  end


  # def decline
  #   @loan_item = AssetLoanItem.find(params[:id])
  #   @loan_item.loan_status = "decline"
  #   @loan_item.item.status = "available"
  #   @loan_item.save
  #   @loan_item.item.save
  #   # @loan_item.update(loan_status: 'declined', evidence: params[:evidence])
  #   redirect_to asset_loans_items_path, notice: 'Item declined successfully.'
  # end

  def decline
    @loan_item = AssetLoanItem.find(params[:id])
    @loan_item.evidence = params[:evidence]
    @loan_item.loan_status = "decline"
    @loan_item.item.status = "available"
    @loan_item.admin_id = current_user.id
    @current_user = current_user
    @loan_item.item.save
    if @loan_item.save
      flash[:errors] = "Item decline successfuly"
      redirect_to  asset_loans_items_path(@loan_item)
    else
      flash[:errors] = @loan_item.errors.full_messages
      redirect_to asset_loans_item_path
    end
  end

  def export_loan
    @loan_items = AssetLoanItem.includes(asset_loan: [:user], item: [:asset_returns, :asset_return_items]).limit(100)

    respond_to do |format|
      format.csv { send_data AssetLoanItem.generate_csv(@loan_items), filename: "loans-#{Date.today}.csv" }
    end
  end

#   private

#   def generate_csv(loan_items)
#     attributes = %w[loan_id item_name item_code user_name loan_date return_estimation_date item_condition necessary admin_name loan_status evidence]

#     CSV.generate(headers: true) do |csv|
#       csv << attributes

#       loan_items.each do |loan_item|
#         csv << [
#           loan_item.asset_loan.code,
#           loan_item.item.name,
#           loan_item.item.code,
#           loan_item.asset_loan.user.name,
#           loan_item.asset_loan.loan_item_datetime,
#           loan_item.asset_loan.return_estimation_datetime,
#           loan_item.item.condition,
#           loan_item.asset_loan.necessary,
#           loan_item.admin.name,
#           loan_item.loan_status,
#           loan_item.evidence
#         ]
#     end
#   end
# end


end
