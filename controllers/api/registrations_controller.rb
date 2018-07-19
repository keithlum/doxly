class Api::RegistrationsController < Devise::SessionsController
  respond_to :json
  before_action :authenticate_super_admin!

  swagger_controller :user, "User"

  def self.add_user_params(user)
    user.param :form, "user[email]", :string, :required, "Email"
    user.param :form, "user[password]", :string, :required, "Password"
    user.param :form, "user[first_name]", :string, :required, "First Name"
    user.param :form, "user[last_name]", :string, :required, "Last Name"
    user.param :form, "user[phone]", :string, :optional, "Phone"
    user.param :form, "user[address]", :string, :optional, "Address"
    user.param :form, "user[company]", :string, :optional, "Company"
    user.param :form, "user[role]", :string, :required, "Role"
  end

  swagger_api :create do |user|
    notes "Permissions: Super Admin"
    RegistrationsController::add_user_params(user)
    response :success, "User created successfully.", :user
    response :bad_request, "Incorrect request/formdata"
    response :unauthorized, "You are unauthorized to access this page."
  end

  def create
    user = User.new(user_params)
    user.activated = true
    user.skip_confirmation!
    if user.save
      success_response(
        {
          user: user.to_hash(false)
        }
      )
    else
      warden.custom_failure!
      error_response(user.errors)
    end
  end

  private
  def user_params
    params.require(:user).permit(
      :email,
      :password,
      :first_name,
      :last_name,
      :phone,
      :address,
      :company,
      :activated,
      :role
    )
  end
end
