class Api::UsersController < ApplicationController
  respond_to :json
  before_action :authenticate_super_admin!
  before_action :set_user, only: [:destroy, :update, :show]
  before_action :ensure_params_exist, only: [:update, :create]

  swagger_controller :user, "User"

  def self.add_user_params(user)
    user.param :form, "user[first_name]", :string, :optional, "First Name"
    user.param :form, "user[last_name]", :string, :optional, "Last Name"
    user.param :form, "user[phone]", :string, :optional, "Phone"
    user.param :form, "user[address]", :string, :optional, "Address"
    user.param :form, "user[company]", :string, :optional, "Company"
  end

  swagger_api :index do
    notes "Permissions: Super Admin"
    response :success, "user record", :user
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :show do
    notes "Permissions: Super Admin"
    param :path, :id, :integer, :required, "User Id"
    response :success, "user record", :user
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :update do |user|
    notes "Permissions: Super Admin"
    UsersController::add_user_params(user)
    param :path, :id, :integer, :required, "user Id"
    response :success, "User updated successfully", :user
    response :unauthorized, "You are unauthorized to access this page."
    response :bad_request, "Incorrect request/formdata"
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :destroy do
    notes "Permissions: Super Admin"
    param :path, :id, :integer, :required, "user Id"
    response :success,"User destroyed successfully"
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  def index
    @users = User.page(@page).per(@per_page) rescue []
    success_response(
      {
        users: @users.map(&:to_hash)
      }
    )
  end

  def create
    @user = User.new(user_params)
    @user.activated = true
    @user.skip_confirmation!
    if @user.save
      success_response(
        {
          user: @user.to_hash(false)
        }
      )
    else
      error_response(@user.errors)
    end
  end

  def update
    if @user.update(user_params)
      success_response(["User updated successfully"])
    else
      error_response(@user.errors)
    end
  end

  def show
    success_response(
      {
        user: @user.to_hash
      }
    )
  end

  def destroy
    if @user.destroy
      success_response(["User destroyed successfully"])
    else
      error_response(@user.errors)
    end
  end

  private
  def set_user
    @user = User.find_by_id(params[:id])
    error_response(["User Not Found"]) if @user.blank?
  end

  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :first_name,
      :last_name,
      :phone,
      :address,
      :company,
      :role
    )
  end

  protected
  def ensure_params_exist
    if params[:user].blank?
      error_response(["User related parameters not found."])
    end
  end
end