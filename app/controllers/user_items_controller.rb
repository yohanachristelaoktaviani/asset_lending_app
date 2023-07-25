class UserItemsController < ApplicationController

  before_action :authenticate_user!, except: [:main]

  def index
    @user_items = Item.order('code ASC').where.not(status: "unavailable").page(params[:page]).per(3)
    if params[:search].present?
      # regex to handle search using coma/ spaces
      search_terms = params[:search].split(/[,\s]+/)
      @user_items = @user_items.where("lower(name) LIKE :search OR lower(code) LIKE :search OR lower(merk) LIKE :search OR lower(condition) LIKE :search  OR lower(description) LIKE :search", search: "%#{search_terms.first.downcase}%")
      search_terms.drop(1).each do |term|
        @user_items = @user_items.or(Item.where("lower(name) LIKE :search OR lower(code) LIKE :search OR lower(merk) LIKE :search OR lower(condition) LIKE :search OR lower(description) LIKE :search", search: "%#{term.downcase}%"))
      end
    end
  end

  def show
    @user_item = Item.find(params[:id])
  end
end
