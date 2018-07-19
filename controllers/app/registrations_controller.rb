class App::RegistrationsController < Devise::RegistrationsController
  def new
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
      :activated
    )
  end
end