class UserAssetReturnsController < ApplicationController

  before_action :authenticate_user!, except: [:main]

  # before_action :set_return, only: [:index, :edit, :new, :create]

  def index
    # @asset_returns = AssetReturnItem.all
    # binding.pry

    #selain menggunakan magic rails, bisa juga menggunakan query sql biasa, kemudian result dimasukkan ke active record base
    # query = "select * from x inner join y on ... where ..."
    # results = ActiveRecord::Base.connection.execute(query)
     @asset_returns = AssetReturnItem.joins(:asset_return).where(asset_return: {user_id: current_user.id}).order('code ASC').page(params[:page]).per(1)

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

  def new
    asset_loan = AssetLoan.find_by(asset_loan
    @asset_return = AssetReturn.new

    @asset_return.code = generate_asset_return_code
    @asset_return.asset_loan_id = asset_loan.id

    binding.pry
    item_ids = asset_loan.asset_loan_items.pluck(:item_id)
    returned_item_ids = AssetReturnItem.where(asset_return_id: AssetReturn.where.not(return_status: "")).pluck(:item_id)
    available_item_ids = item_ids - returned_item_ids
    # @asset_return.asset_return_item_id = items.id

    available_items = Item.where(id: available_item_ids)

    available_items.each_with_index do |item, index|
    @asset_return.asset_return_items.build(
      item_id: item.id,
      actual_item_condition: item.condition
    )
    end
    @current_user_name = current_user.name
    # respond_to do |format|
    #   format.html
    #   format.json { render json: { asset_return: @asset_return, asset_return_item: @asset_return_item } }
    # end
  end

  def create
    # binding.pry
    @asset_return = AssetReturn.new(return_params)
    asset_loan = AssetLoan.find_by(user_id: current_user.id)
    @asset_return.user_id = current_user.id
    @asset_return.asset_loan_id = asset_loan.id

    # binding.pry
    if @asset_return.save
      params[:asset_return][:asset_return_items].each do |_, item|
        item_id = item[:item_id]
        actual_item_condition = item[:actual_item_condition]

        asset_return_item = @asset_return.asset_return_items.build(
          item_id: item_id,
          actual_item_condition: actual_item_condition
        )

        if @asset_return.actual_return_datetime <= @asset_return.asset_loan.return_estimation_datetime
          @asset_return.return_status = "on time"
        else
          @asset_return.return_status = "late"
        end

        if actual_item_condition == "good"
          item = Item.find(item_id)
          item.update(condition: "good")
        elsif actual_item_condition == "damage"
          item = Item.find(item_id)
          item.update(condition: "damage")
        elsif actual_item_condition == "unusable"
          item = Item.find(item_id)
          item.update(condition: "unusable")
          item.save
        end

        @asset_return.save
      end

      flash[:success] = "New return item was successfully created"
      redirect_to user_asset_returns_path(@asset_return)
    else
      puts 'ERROR ', @asset_return.errors.full_messages
      # flash[:danger] = @pokemon.errors.full_messages
      redirect_to user_asset_returns_path
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


end
