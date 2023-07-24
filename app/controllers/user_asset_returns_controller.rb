class UserAssetReturnsController < ApplicationController

  before_action :authenticate_user!, except: [:main]

  # before_action :set_return, only: [:index, :edit, :new, :create]

  def index
    # @asset_returns = AssetReturnItem.all
    # binding.pry

    #selain menggunakan magic rails, bisa juga menggunakan query sql biasa, kemudian result dimasukkan ke active record base
    # query = "select * from x inner join y on ... where ..."
    # results = ActiveRecord::Base.connection.execute(query)
     @asset_returns = AssetReturnItem.joins(:asset_return).where(asset_return: {user_id: current_user.id}).order('code ASC').page(params[:page]).per(5)

     if params[:search].present?
      search_term = "%#{params[:search].downcase}%"

      @asset_returns = AssetReturnItem.joins(asset_return: :user)
                                 .includes(:item, asset_return: :user)
                                 .joins('LEFT JOIN users admin ON admin.id = asset_return_items.admin_id')
                                #  Left join -> menghubungkan table dan menampilkan semua data yg terdapat di kiri table, data yg kosong akan bernilai NULL
                                .where("lower(asset_returns.code) LIKE :search OR lower(items.name) LIKE :search OR lower(asset_return_items.actual_item_condition)
                                 LIKE :search  OR lower(users.name) LIKE :search OR (asset_returns.actual_return_datetime AT time zone 'utc' AT time zone 'Asia/Jakarta')::text
                                 LIKE :search OR lower(asset_returns.return_status) LIKE :search", search: "%#{params[:search].downcase}%")
    end

  end

  def edit
  end

  # V1
  # def new
  #   @asset_loan = AssetLoan.find(params[:loan_item_id])
  #   # @asset_loan = AssetLoan.find(params[:id])
  #   @asset_return = AssetReturn.new
  #   @asset_return.code = generate_asset_return_code
  #   @asset_return.asset_loan_id = @asset_loan.id
  #   @current_user_name = current_user.name
  #   @asset_loan_item = AssetLoanItem.find_by(asset_loan_id: @asset_return.asset_loan_id)
  #   # binding.pry
  #   # Build asset_return_items for eligible items that can be returned
  #   @asset_loan_items = AssetLoanItem.where(asset_loan_id: @asset_return.asset_loan_id, loan_status: 'accepted')
  #   @asset_return_items = @asset_loan_items.map do |asset_loan_item|
  #     AssetReturnItem.new(item_id: asset_loan_item.item_id, actual_item_condition: asset_loan_item.item.condition)
  #   end

  # end

  # Ex
  def new
    @asset_loan = AssetLoan.find(params[:loan_item_id])
    # @asset_loan = AssetLoan.find(params[:id])
    @asset_return = AssetReturn.new
    @asset_return.user_id = current_user.id
    @asset_return.code = generate_asset_return_code
    @asset_return.asset_loan = @asset_loan
    @current_user_name = current_user.name
    @asset_loan_items = @asset_loan.asset_loan_items.where(loan_status: 'accepted')
    # binding.pry
    # Build asset_return_items for eligible items that can be returned
    @asset_loan_items.each do |loan_item|
      @asset_return.asset_return_items.build(item_id: loan_item.item_id, actual_item_condition: loan_item.item.condition)
    end
    @asset_return.save!
  end

  def create
    @asset_return = AssetReturn.new(return_params)
    @asset_return.user_id = current_user.id

    # binding.pry
    if @asset_return.save
      update_item_conditions(@asset_return) # Update item conditions based on actual_item_condition

      flash[:success] = "New return item was successfully created"
      redirect_to user_asset_returns_path
    else
      flash[:error] = @asset_return.errors.full_messages
      redirect_to new_user_asset_returns_path
    end
  end



  private

  def return_params
    params.require(:asset_return).permit(:code, :asset_loan_id, :user_id, :actual_return_datetime, asset_return_items_attributes: [:id, :item_id, :actual_item_condition, :admin_id, :asset_return_id, :item_name])
  end

  def assign_text_field_value(index)
    params[:asset_return][:asset_return_items_attributes][index.to_s][:actual_item_condition]
  end

  def generate_asset_return_code
    last_code = AssetReturn.maximum(:code)
    if last_code.nil?
      'RE00001'
    else
      numeric_part = last_code.scan(/\d+/).first.to_i
      next_numeric_part = numeric_part + 1
      "RE" + next_numeric_part.to_s.rjust(5, '0')
    end
  end

  def update_item_conditions(asset_return)
    asset_return.asset_return_items.each do |asset_return_item|
      item = Item.find(asset_return_item.item_id)

      case asset_return_item.actual_item_condition
      when 'good'
        item.update(condition: 'good')
      when 'damage'
        item.update(condition: 'damage')
      when 'unusable'
        item.update(condition: 'unusable')
      end
    end
  end


end
