class ItemsController < ApplicationController

  def index
    @items = Item.order('code ASC')
  end

  def new
    @item = Item.new
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


  private

  def item_params
    params.require(:item).permit(:code, :name, :merk, :vendor_name, :condition, :status, :description, :image)
  end


end
