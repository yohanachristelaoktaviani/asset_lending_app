class ItemsController < ApplicationController
  require 'csv'
  require 'date'
  require 'net/http'

  protect_from_forgery with: :exception
  before_action :authenticate_user!, except: [:main]
  before_action :authenticate_admin!, only: [:new, :create, :index, :show, :edit, :update]


  # def index
  #   @items = Item.order('code ASC').page(params[:page]).per(10)
  #   if params[:search].present?
  #     # regex to handle search using coma/ spaces
  #     search_terms = params[:search].split(/[,\s]+/)
  #     first_term = search_terms.first.downcase
  #     @items = @items.where("lower(name) LIKE :search OR lower(code) LIKE :search OR lower(item_type) LIKE :search OR lower(condition) LIKE :search OR lower(vendor_name) LIKE :search OR lower(status) LIKE :search OR lower(serial_number) LIKE :search", search: "%#{first_term}%")
  #     search_terms.drop(1).each do |term|
  #       @items = @items.or(Item.where("lower(name) LIKE :search OR lower(code) LIKE :search OR lower(item_type) LIKE :search OR lower(condition) LIKE :search OR lower(vendor_name) LIKE :search OR lower(status) LIKE :search OR lower(serial_number) LIKE :search", search: "%#{term.downcase}%"))
  #     end

  #     if search_terms.include?("available")
  #       @items = @items.where(status: "available")
  #     elsif search_terms.include?("unavailable")
  #       @items = @items.where(status: "unaivailable")
  #     end
  #   end
  # end

  # def index
  #   @items = Item.order('code ASC').page(params[:page]).per(10)
  #   if params[:search].present?
  #     search_terms = params[:search].split(/[^\w,: ]+/)
  #     datetime_string = search_terms.find { |term| term.match?(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/) }

  #     if datetime_string.present?
  #       datetime = DateTime.parse(datetime_string)
  #       puts "Parsed datetime: #{datetime}"
  #       # @items = @items.where("items.purchase_date = :datetime", datetime)
  #       @items = @items.where("items.purchase_date >= ? AND items.purchase_date <= ?", datetime.beginning_of_day, datetime.end_of_day)
  #       puts "SQL query: " + @items.to_sql

  #     else

  #       search_query = "%#{params[:search].downcase}%"
  #       @items = @items.where("lower(name) LIKE ? OR lower(code) LIKE ? OR lower(item_type) LIKE ? OR lower(condition) LIKE ? OR lower(vendor_name) LIKE ? OR lower(status) LIKE ? OR lower(serial_number) LIKE ?", search_query, search_query, search_query, search_query, search_query, search_query, search_query)

  #       if search_terms.include?("available")
  #         @items = @items.where(status: "available")
  #       elsif search_terms.include?("unavailable")
  #         @items = @items.where(status: "unavailable")
  #       end
  #     end
  #   end
  # end

  def index
    @items = Item.order('code ASC').page(params[:page]).per(10)
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @items = @items.where("lower(name) LIKE :search
                             OR lower(code) LIKE :search
                             OR lower(item_type) LIKE :search
                             OR lower(condition) LIKE :search
                             OR lower(vendor_name) LIKE :search
                             OR lower(status) LIKE :search
                             OR lower(serial_number) LIKE :search
                             OR (purchase_date AT time zone 'utc' AT time zone 'Asia/Jakarta')::text LIKE :search", search: search_term)
      if search_term.include?("available")
        @items = @items.where(status: "available")
      elsif search_term.include?("unavailable")
        @items = @items.where(status: "unavailable")
      end
    end
  end

  def new
    @item = Item.new
    # @item.code = generate_item_code
  end

  def create
    @item = Item.new(item_params)
    @item.status = "available"
    if item_params["purchase_date"].present?
      formatted_loan_datetime = DateTime.strptime(item_params["purchase_date"], "%Y-%m-%d")
      @item.purchase_date =  formatted_loan_datetime.strftime("%Y-%m-%dT")
      @item.admin_id = current_user.id if current_user.admin?
    end
    if @item.save
      @item.selected_item = params[:item][:selected_item] == '1'
      if item_params[:image].present?
        item_params[:image].each do |image|
          unless @item.image.attached?
          @item.image.attach(image)
        end
      end
      end
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
    if @item.purchase_date.present?
      @item.purchase_date = @item.purchase_date.strftime("%Y-%m-%d")
    end

  end

  def show
    @item = Item.find(params[:id])
  end

  def update
    @item = Item.find(params[:id])
    # @item.update(item_params)
    # flash[:success] = "Item was successfully updated"
    # redirect_to items_path
    # binding.pry
    @item.admin_id = current_user.id if current_user.admin?

    if item_params["purchase_date"].present?
      formatted_purchase_datetime = DateTime.strptime(item_params["purchase_date"], "%Y-%m-%d")
    end
    @item.attributes = item_params
    if formatted_purchase_datetime.present?
      @item.purchase_date = formatted_purchase_datetime.strftime("%Y-%m-%dT")
    end
    if @item.save
      @item.selected_item = params[:item][:selected_item] == '1'
      flash[:success] = "Item was successfully updated"
      redirect_to items_path
    else
      puts 'ERROR ', @item.errors.full_messages
      flash[:errors] = @item.errors.full_messages
      redirect_to edit_item_path
    end
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
    @items = Item.all
      respond_to do |format|
        format.html
        format.csv do
        csv_data = Item.to_csv(@items)
        # respond_to do |format|
        #   format.js { render plain: csv_data }
        #   format.csv { send_data csv_data, filename: "items-#{Date.today}.csv" }
        # end
        send_data csv_data, filename: "items-#{Date.today}.csv"
      end
    end
  end

  def import_item
    if params[:file].present?
      file = params[:file].tempfile
      imported_items = 0
      CSV.foreach(file, headers: true) do |row|
        item_params = row.to_hash
        item = Item.new(item_params)
        item.status = "available"
        if item_params["purchase_date"].present?
          formatted_purchase_datetime = DateTime.strptime(item_params["purchase_date"], "%Y-%m-%d")
          item.purchase_date = formatted_purchase_datetime.strftime("%Y-%m-%dT")
          item.admin_id = current_user.id if current_user.admin?
        end
        if item.save
          imported_items += 1
          if item_params["image"].present?
            item_params["image"].each do |image|
              item.image.attach(image)
            end
          end
        end
      end
      flash[:success] = "#{imported_items} items successfully imported."
    else
      flash[:errors] = "Please select a CSV file to import."
    end
    redirect_to items_path
  end

  def history
    @item = Item.find(params[:id])
    @versions = @item.versions
  end

  def download_template
    # send_file(
    #   "#{Rails.root}/path/to/items_template.csv",
    #   filename: "items_template.csv",
    #   type: "text/csv"
    # )
    remote_file_url = 'https://drive.google.com/file/d/12lWxEj8mMoDbiOuCBHdOneIeNMfW385w/view?usp=sharing'

    uri = URI(remote_file_url)
    response = Net::HTTP.get_response(uri)

    if response.is_a?(Net::HTTPSuccess)
      send_data response.body,
      filename: 'items_template.csv',
      type: 'text/csv',
      disposition: 'attachment'
    else
      flash[:errors] = 'failed to fetch remote CSV file.'
      redirect_to items_path
    end
  end


  private

  def item_params
    params.require(:item).permit(:code, :name, :item_type, :vendor_name, :condition, :status, :description, :location, :serial_number, :selected_item, :purchase_date, image: [])
  end

  def generate_item_code
    if last_code.nil?
      'AUK000001'
    else
      numeric_part = last_code.scan(/\d+/).first.to_i
      next_numeric_part = numeric_part + 1
      "AUK" + next_numeric_part.to_s.rjust(6, '0')
    end
  end

  def authenticate_admin!
    redirect_to dashboards_path unless current_user.role == "admin"
  end


end
