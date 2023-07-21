class UsersController < ApplicationController
  require 'csv'
  require 'date'

  before_action :authenticate_user!, except: [:main]

  # layout :users_layout

  def new
    @department = Department.all
    @position = Position.all
    @user = User.new
    @user.code = generate_employee_id
  end

  def create
    @user = User.new(user_params)
    # binding.pry

    if @user.save
      flash[:success] = "New user was successfully created"
      redirect_to users_path(@user)
    else
      puts 'ERROR ', @user.errors.full_messages
      flash[:errors] = @user.errors.full_messages
      redirect_to new_user_path
    end
  end

  def index
    @users = User.order('code ASC').page(params[:page]).per(5)
    if params[:search].present?
      search_term = "%#{params[:search].downcase}%"
      @users = @users.includes(:department).includes(:position)
                     .where("lower(users.name) LIKE :search OR lower(users.code) LIKE :search OR lower(users.role) LIKE :search OR lower(users.email) LIKE :search OR lower(departments.code_name) LIKE :search OR lower(positions.code_name) LIKE :search", search: search_term)
                     .references(:department)
                     .references(:position)
    end
  end

  # department_ids = Department.where("LOWER(code_name) IN (?)", search_terms.map(&:downcase)).pluck(:id)


      # @users = @users.joins(:department)
      #                .where("lower(users.name) LIKE :search OR lower(users.code) LIKE :search OR lower(users.role) LIKE :search OR lower(users.email) LIKE :search OR departments.code_name IN (:search_terms) OR users.department_id IN (:department_ids)", search: "%#{params[:search].downcase}%", search_terms: search_terms.map(&:downcase), department_ids: department_ids)


  def edit
    @user = User.find(params[:id])
    @department = Department.all
    @position = Position.all
  end

  def update
    @user = User.find(params[:id])
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
    @user.update(user_params)
    flash[:success] = "User was succesfully updated"
    redirect_to users_path
  end

  def show
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:errors] = "User was successfully deleted"
      redirect_to users_path(@user)
    else
      puts 'ERROR ', @user.errors.full_messages
      flash[:errors] = @user.errors.full_messages
      redirect_to users_path
    end
  end

  def export_user
    @users = User.all.limit(100)

    respond_to do |format|
      format.html
      format.csv do
        csv_data = User.to_csv(@users)
        send_data csv_data, filename: "users-#{Date.today}.csv"
      end
    end
  end


  private

  def user_params
    params.require(:user).permit(:code, :name, :email, :password, :password_confirmation, :department_id, :position_id, :role)
  end

  def users_layout
    @user.special? ? "special" : "items"
  end

  layout Proc.new { |controller| controller.request.xhr? ? "popup" : "application" }

  def generate_employee_id
    last_code = User.maximum(:code)
    if last_code.nil?
      'UKI001'
    else
      numeric_part = last_code.scan(/\d+/).first.to_i
      next_numeric_part = numeric_part + 1
      "UKI" + next_numeric_part.to_s.rjust(3, '0')
    end
  end


end
