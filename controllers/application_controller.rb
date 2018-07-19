class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  skip_before_action :verify_authenticity_token
  before_action      :set_authenticate_params

  # user role validate
  def authenticate_user!
    if current_user.blank?
      respond_to do |format|
        format.html { redirect_to new_app_user_session_path }
        format.json { unauthorized_response(401) }
      end
      
    end
  end

  def authenticate_super_admin!
    if current_user.blank?
      unauthorized_response(401)
    elsif !current_user.is_super?
      unauthorized_response
    end
  end

  def authenticate_organization_admin!
    if current_user.blank?
      unauthorized_response(401)
    elsif !current_user.is_organization_admin?(params[:organization_id] || params[:id])
      unauthorized_response
    end
  end

  def authenticate_organization_member!
    if current_user.blank?
      unauthorized_response(401)
    elsif !current_user.is_organization_member?(params[:organization_id] || params[:id] || current_user.organization.id)
      unauthorized_response
    end
  end

  def authenticate_org_deal_admin!
    if current_user.blank?
      unauthorized_response(401)
    elsif !current_user.is_org_deal_admin?(params[:deal_id] || params[:id])
      unauthorized_response
    end
  end

  def authenticate_deal_collaborator!
    if current_user.blank?
      unauthorized_response(401)
    elsif !current_user.is_deal_collaborator?(params[:deal_id] || params[:id])
      unauthorized_response
    end
  end

  # API responses
  def success_response(data, status = 200)
    render(
      json: {
        status: 'success',
        data: data,
        errors: nil,
      },
      status: status
    )
  end

  def error_response(messages, status = 400)
    render(
      json: {
        status: 'error',
        data: nil,
        errors: {
          messages: messages
        }
      },
      status: status
    )
  end

  def unauthorized_response(status = 403)
    render(
      json: {
        status: 'unauthorized',
        data: nil,
        errors: {
          messages: ['You are unauthorized to access this page.']
        }
      },
      status: status
    )
  end

  def ensure_params_exist(object)
    if params[object].blank?
      error_response(["object related parameters not found."])
    end
  end

  def set_authenticate_params
    if params[:organization_id].blank?
      if !params[:organization].blank? and !params[:organization][:id].blank?
        params[:organization_id] = params[:organization][:id]
      end
      if !params[:deal].blank? and !params[:deal][:organization_id].blank?
        params[:organization_id] = params[:deal][:organization_id]
      end
    end
  end

  # Get Box token
  def box_token(type = 'enterprise', user_id = 0)
    token = Boxr::get_enterprise_token
    if (type == 'user')
      token = Boxr::get_use_token user_id
    end
    token.access_token
  end

  # Get Box Client
  def box_client(type = 'enterprise', user_id = 0)
    access_token = box_token(type, user_id)
    Boxr::Client.new(access_token)
  end

  # Other support
  def set_peginate
    @per_page = (params[:per_page].to_i <= 0 ? PER_PAGE : params[:per_page].to_i)
    @page = (params[:page].to_i <= 0 ? 1 : params[:page].to_i)
  end
end
