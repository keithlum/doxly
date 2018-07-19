class App::PasswordsController < Devise::PasswordsController
  def edit
    super
  end

  def create
    self.resource = resource_class.send_reset_password_instructions(resource_params)
    yield resource if block_given?

    if successfully_sent?(resource)
      flash[:notice] = "Sent password reset email"
      respond_with({}, location: after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  def update
    super
  end
end