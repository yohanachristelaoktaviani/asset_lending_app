class UserAssetReturnsController < ApplicationController

  require 'active_support/time'

  before_action :authenticate_user!, except: [:main]

  # before_action :set_return, only: [:index, :edit, :new, :create]

  def index
    # @asset_returns = AssetReturnItem.all
    # binding.pry

    #selain menggunakan magic rails, bisa juga menggunakan query sql biasa, kemudian result dimasukkan ke active record base
    # query = "select * from x inner join y on ... where ..."
    # results = ActiveRecord::Base.connection.execute(query)

     if params[:search].present?
      search_term = "%#{params[:search].downcase}%"

      @asset_returns = AssetReturnItem.joins(asset_return: :user)
                                 .includes(:item, asset_return: :user)
                                 .joins('LEFT JOIN users admin ON admin.id = asset_return_items.admin_id')
                                 .joins('LEFT JOIN items ON items.id = asset_return_items.item_id')
                                #  Left join -> menghubungkan table dan menampilkan semua data yg terdapat di kiri table, data yg kosong akan bernilai NULL
                                  .where("lower(asset_returns.code) LIKE :search OR lower(items.name) LIKE :search OR lower(asset_return_items.actual_item_condition)
                                  LIKE :search  OR lower(users.name) LIKE :search OR (asset_returns.actual_return_datetime AT time zone 'utc' AT time zone 'Asia/Jakarta')::text
                                  LIKE :search OR lower(asset_returns.return_status) LIKE :search", search: search_term)
                                 .where(asset_returns: {user_id: current_user.id})
     else
      @asset_returns = AssetReturnItem.joins(asset_return: :user)
                                      .includes(:item, asset_return: :user)
                                      .joins('LEFT JOIN users admin ON admin.id = asset_return_items.admin_id')
                                      .joins('LEFT JOIN items ON items.id = asset_return_items.item_id')
                                      .where(asset_returns: {user_id: current_user.id})



    end
      @asset_returns = @asset_returns.page(params[:page]).per(10).order('asset_returns.code DESC')
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
    if params[:asset_loan_id].present?
      @asset_loan = AssetLoan.find(params[:asset_loan_id])
    elsif params[:loan_item_id].present?
     @asset_loan = AssetLoan.find(params[:loan_item_id])
    else
      # redirect_to root_path, alert: "Invalid request"
      return
    end
    # @asset_loan = AssetLoan.find(params[:id])
    @asset_return = AssetReturn.new
    @asset_return.user_id = current_user.id
    @asset_return.code = generate_asset_return_code
    @asset_return.asset_loan = @asset_loan

    if current_user.admin?
      @current_user_name = @asset_loan.user.name
    else
      @current_user_name = current_user.name
    end


    @asset_loan_items = @asset_loan.asset_loan_items.where(loan_status: 'accepted')
    # binding.pry
    # Build asset_return_items for eligible items that can be returned
    @asset_loan_items.each do |loan_item|
      @asset_return.asset_return_items.build(item_id: loan_item.item_id, actual_item_condition: loan_item.item.condition)
      # actual_item_condition: loan_item.item.condition
    end
    # @asset_return.save!
  end

  def create
    @id = params[:asset_return][:loan_id]
    @asset_loan = AssetLoan.find(params[:asset_return][:loan_id])
    @asset_return = AssetReturn.new
    @estimation_return = @asset_loan.return_estimation_datetime
    @asset_return.user_id = current_user.id
    @asset_return.code = generate_asset_return_code
    @asset_return.asset_loan_id = @id
    if current_user.admin?
      @asset_return.user_id = @asset_loan.user.id
    else
      @asset_return.user_id = current_user.id
    end

    @asset_loan.asset_loan_items.each_with_index do |return_item, index|
      is_destroyed = params[:asset_return]["asset_return_items"]["#{index}"]["data_is_destroyed"]
      if is_destroyed == "true"
        # Mark item as destroyed (do not build asset_return_items)
      else
        @asset_return.asset_return_items.build(
          item_id: return_item.item_id,
          actual_item_condition: return_item.item.condition
        )
      end
    end
    return_params = @asset_loan
    # @loan_item.user_id = current_user.id
    if return_params["actual_return_datetime"].present?
      formatted_return_datetime = DateTime.strptime(return_params["actual_return_datetime"], "%m/%d/%Y %H:%M:%S")
      @asset_return.actual_return_datetime = formatted_return_datetime.in_time_zone('Asia/Jakarta')
    end

    actual_return_local = @asset_return.actual_return_datetime
    if actual_return_local < @asset_loan.return_estimation_datetime
      @asset_return.return_status = "early"
    elsif actual_return_local == @asset_loan.return_estimation_datetime
      @asset_return.return_status = "on time"
    elsif actual_return_local > @asset_loan.return_estimation_datetime
      @asset_return.return_status = "late"
    end

    if @asset_return.save
      # update_item_conditions(@asset_return) # Update item conditions based on actual_item_condition

      flash[:success] = "New return item was successfully created"
      if current_user.admin?
        redirect_to asset_return_items_path
      else
        redirect_to user_asset_returns_path
      end
    else
      flash[:errors] = @asset_return.errors.full_messages
      redirect_to new_user_asset_return_path(loan_item_id: @id)
    end
  end

  private

  def return_params
    params.require(:asset_return).permit(:code, :asset_loan_id, :user_id, :actual_return_datetime, asset_return_items_attributes: [:id, :item_id, :admin_id, :asset_return_id, :item_name, :data_is_destroyed])
  end

  # def assign_text_field_value(index)
  #   params[:asset_return][:asset_return_items_attributes][index.to_s][:actual_item_condition]
  # end

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
      when 'tidak layak pakai'
        item.update(condition: 'tidak layak pakai')
      end
    end
  end


end
