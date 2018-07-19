class Api::AccountsController < ApplicationController
  respond_to :json

  before_action :authenticate_user!, except: [:create]
  before_action :ensure_params_exist, only: [:create, :update]
  before_action :set_user, only: [:destroy, :update]

  swagger_controller :account, "Account"

  def self.add_account_params(user)
    user.param :form, "user[email]",      :string, :required, "Email"
    user.param :form, "user[password]",   :string, :required, "password"
    user.param :form, "user[first_name]", :string, :required, "First Name"
    user.param :form, "user[last_name]",  :string, :required, "Last Name"
    user.param :form, "user[phone]",      :string, :optional, "Phone"
    user.param :form, "user[address]",    :string, :optional, "Address"
    user.param :form, "user[company]",    :string, :optional, "Company"
  end

  swagger_api :index do
    notes "Permissions: Self User (logged in)"
    response :success, "user record", :user
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :create do |user|
    notes "Permissions: Guest"
    AccountsController::add_account_params(user)
    response :success, "User created successfully.", :user
    response :bad_request, "Incorrect request/formdata"
  end

  swagger_api :update do |user|
    notes "Permissions: Self User (logged in)"
    AccountsController::add_account_params(user)
    response :success, "User updated successfully", :user
    response :unauthorized, "You are unauthorized to access this page."
    response :bad_request, "Incorrect request/formdata"
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :destroy do
    notes "Permissions: Self User (logged in)"
    response :success,"User destroyed successfully"
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  def index
    success_response(
      {
        user: current_user.to_hash(false)
      }
    )
  end

  def create
    @user = User.new(user_params)
    @user.activated = false
    @user.role = USER_NORMAL if @user.role.blank?
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
    Devise.reconfirmable = false
    if @user.update(user_params)
      success_response(
        {
          user: @user.to_hash(false)
        }
      )
    else
      error_response(@user.errors)
    end
    Devise.reconfirmable = true
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
    @user = current_user
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
      :company
    )
  end

  protected
  def ensure_params_exist
    if params[:user].blank?
      error_response(["User related parameters not found."])
    end
  end

end
