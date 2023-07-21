class ItemsController < ApplicationController
  require 'csv'
  require 'date'

  before_action :authenticate_user!, except: [:main]

  def index
    @items = Item.order('code ASC').page(params[:page]).per(5)
    if params[:search].present?
      # regex to handle search using coma/ spaces
      search_terms = params[:search].split(/[,\s]+/)
      @items = @items.where("lower(name) LIKE :search OR lower(code) LIKE :search OR lower(merk) LIKE :search OR lower(condition) LIKE :search OR lower(vendor_name) LIKE :search OR lower(status) LIKE :search OR lower(description) LIKE :search", search: "%#{search_terms.first.downcase}%")
      search_terms.drop(1).each do |term|
        @items = @items.or(Item.where("lower(name) LIKE :search OR lower(code) LIKE :search OR lower(merk) LIKE :search OR lower(condition) LIKE :search OR lower(vendor_name) LIKE :search OR lower(status) LIKE :search OR lower(description) LIKE :search", search: "%#{term.downcase}%"))
      end
    end
  end

  def new
    @item = Item.new
    @item.code = generate_item_code
  end

  def create
    @item = Item.new(item_params)
    @item.status = "available"

    if @item.save
      flash[:success] = "New item was successfully added"
      redirect_to items_path(@item)
    else
      puts 'ERROR ', @item.errors.full_messages
      flash[:errors] = @item.errors.full_messages
      redirect_to new_item_path
    end
  end

  def edit
    @item = Item.find(params[:id])
  end

  def show
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    @item.update(item_params)
    flash[:success] = "Item was successfully updated"
    redirect_to items_path
  end

  def destroy
    @item = Item.find(params[:id])
    if @item.destroy
      flash[:errors] = "Item was successfully deleted"
      redirect_to items_path(@item)
    else
      puts 'ERROR ', @item.errors.full_messages
      flash[:errors] = @item.errors.full_messages
      redirect_to items_path
    end
  end

  def export_item
    @items = Item.all.limit(100)
      respond_to do |format|
        format.html
        format.csv do
        csv_data = Item.to_csv(@items)
        respond_to do |format|
          format.js { render plain: csv_data }
          format.csv { send_data csv_data, filename: "items-#{Date.today}.csv" }
        end
      end
    end
  end


  private

  def item_params
    params.require(:item).permit(:code, :name, :merk, :vendor_name, :condition, :status, :description, :image)
  end

  def generate_item_code
    last_code = Item.maximum(:code)
    if last_code.nil?
      'AUK000001'
    else
      numeric_part = last_code.scan(/\d+/).first.to_i
      next_numeric_part = numeric_part + 1
      "AUK" + next_numeric_part.to_s.rjust(6, '0')
    end
  end

end
