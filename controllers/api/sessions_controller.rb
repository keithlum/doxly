class Api::SessionsController < Devise::SessionsController
  respond_to :json

  before_action :ensure_params_exist, only: [:create]

  swagger_controller :sessions, "Sessions"

  swagger_api :create do
    summary "Permissions: Guest"
    param :form, "user[email]", :string, :required, "Email"
    param :form, "user[password]", :string, :required, "Password"
    response :success, "Logged in user record", :user
    response :not_acceptable, "Incorrect login or password"
  end

  swagger_api :destroy do
    summary "Permissions: Logged in user"
    response :no_content
  end

  def create
    resource = User.find_for_database_authentication(
      email: params[:user][:email]
    )

    if resource and resource.valid_password?(params[:user][:password])
      sign_in("user", resource)
      success_response({user: resource.to_hash})
    else
      error_response(["Incorrect login or password"],406)  
    end
  end

  def destroy
    sign_out(current_user)
  end

  protected
  def ensure_params_exist
    if params[:user].blank?
      error_response(["Incorrect login or password"],406)
    end
  end
end