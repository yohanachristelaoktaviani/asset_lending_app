class AssetLoansItemsController < ApplicationController

  before_action :authenticate_user!, except: [:main]
  before_action :authenticate_admin!

  def index
    @loan_items = AssetLoanItem.joins(asset_loan: :user).order('asset_loans.code DESC')

    if params[:search].present?
      search_terms = params[:search].split(/[^\w,: ]+/)

      datetime_string = search_terms.find { |term| term.match?(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}/) }
      date_string = search_terms.find { |term| term.match?(/\d{4}-\d{2}-\d{2}/) }
      time_string = search_terms.find { |term| term.match?(/\d{2}:\d{2}/) }

      if datetime_string.present?
        datetime = DateTime.strptime(datetime_string, '%Y-%m-%d %H:%M')
        @loan_items = @loan_items.where(asset_loans: { loan_item_datetime: datetime..datetime })
      elsif date_string.present?
        date = Date.strptime(date_string, '%Y-%m-%d')
     @loan_items = @loan_items.where("DATE(asset_loans.loan_item_datetime AT time zone 'Asia/Jakarta') = :date")
      elsif time_string.present?
        time = Time.parse(time_string)
        @loan_items = @loan_items.where("CAST(asset_loans.loan_item_datetime AT time zone 'Asia/Jakarta' AS TIME) = :time", time: time.strftime('%H:%M:%S'))
      else
        search_query = "%#{params[:search].downcase}%"
        @loan_items = @loan_items.joins(asset_loan: :user)
                                 .includes(:item, asset_loan: :user)
                                 .joins('LEFT JOIN users admin ON admin.id = asset_loan_items.admin_id')
                                 .joins('LEFT JOIN items ON items.id = asset_loan_items.item_id')
                                 .where("lower(asset_loans.code) LIKE :search OR lower(items.name) LIKE :search OR lower(items.code) LIKE :search OR lower(items.condition) LIKE :search OR lower(asset_loans.necessary) LIKE :search OR lower(asset_loan_items.loan_status) LIKE :search OR lower(asset_loan_items.evidence) LIKE :search OR lower(users.name) LIKE :search OR lower(admin.name) LIKE :search", search: search_query)
      end
    end

    @loan_items = @loan_items.page(params[:page]).per(10)
  end




  def show
    @loan_item = AssetLoanItem.find(params[:id])
    @admins = User.admins
  end

  def accept
    @loan_item = AssetLoanItem.find(params[:id])
    @loan_item.loan_status = "accepted"
    @loan_item.evidence = " "
    @loan_item.item.status = "unavailable"
    @loan_item.admin_id = params[:name] if params[:name].present?
    @loan_item.item.save
    @loan_item.save
    flash[:success] = "Accepted succesfully"
    redirect_to asset_loans_items_path(@loan_item)
  end

  def cancel
    @loan_item = AssetLoanItem.find(params[:id])
    @loan_item.loan_status = "waiting"
    @loan_item.item.status = "available"
    @loan_item.evidence = params[:evidence]
    @loan_item.admin_id = params[:name] if params[:name].present?
    @loan_item.save
    @loan_item.item.save
    flash[:success] = "Canceled succesfully"
    redirect_to asset_loans_items_path(@loan_item)
  end

  def new
    @loan_item = AssetLoanItem.new
    @items = Item.where(status: "available").where.not(condition: "tidak layak pakai")
    @loan_item.asset_loan_items.build
  end

  def create
    @loan_item = AssetLoanItem.new(loan_item_params)
    # Perform any additional logic or adjustments specifically for admins
    if @loan_item.save
      flash[:success] = "Loan item added successfully."
      redirect_to asset_loans_items_path
    else
      render :new
    end
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
    # @loan_item.admin_id = current_user.id
    # @current_user = current_user
    # @users = User.all
    @loan_item.admin_id = params[:name] if params[:name].present?
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
    @loan_items = AssetLoanItem.includes(asset_loan: [:user], item: [:asset_returns, :asset_return_items])

    session[:csv_filename] = "loans-#{Date.today}"

    respond_to do |format|
      format.csv { send_data AssetLoanItem.generate_csv(@loan_items), filename: "#{session[:csv_filename]}.csv" }
    end
  end

  private

  def authenticate_admin!
    redirect_to dashboards_path unless current_user.role == "admin"
  end

end
