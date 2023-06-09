class UsersController < ApplicationController
  def new
    @department = Department.all
    @position = Position.all
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    # binding.pry
    @user.save
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
    @users = User.order('code ASC')
  end

  def edit
    @user = User.find(params[:id])
    @department = Department.all
    @position = Position.all
  end

  def update
    @user = User.find(params[:id])
    @user.update(user_params)
    redirect_to users_path
  end

  def show
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      flash[:danger] = "User was successfully deleted"
      redirect_to users_path(@user)
    else
      puts 'ERROR ', @user.errors.full_messages
      flash[:danger] = @user.errors.full_messages
      redirect_to users_path
    end
  end


  def user_params
    params.require(:user).permit(:code, :name, :email, :password, :password_confirmation, :department_id, :position_id, :role)
  end

end
