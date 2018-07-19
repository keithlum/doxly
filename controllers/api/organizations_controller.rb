class Api::OrganizationsController < ApplicationController
  respond_to :json

  before_action :authenticate_super_admin!, only: [:index, :create]
  before_action :authenticate_organization_admin!, only: [:update, :destroy]
  before_action :authenticate_organization_member!, only: [:show]
  before_action :ensure_params_exist, only: [:create, :update]
  before_action :set_organization, only: [:update, :destroy, :show]
  before_action :set_peginate, only: [:index]

  swagger_controller :organization, "Organization"

  def self.add_oraganization_params(organization)
    organization.param :form, "organization[name]", :string, :required, "Name"
    organization.param :form, "organization[email_domain]", :string, :required, "Email Domain"
    organization.param :form, "organization[phone]", :string, :required, "Phone"
    organization.param :form, "organization[address]", :string, :required, "Address"
    organization.param :form, "organization[activated]", :boolean, :optional, "Activated"
  end

  swagger_api :index do
    notes "Permissions: Super Admin"
    response :success, "List of organization records", :organization
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :show do
    notes "Permissions: Organization Member"
    param :path, :id, :integer, :required, "Organization Id"
    response :success, "organization record", :organization
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :create do |organization|
    notes "Permissions: Super Admin"
    OrganizationsController::add_oraganization_params(organization)
    response :success, "Created organization record", :organization
    response :bad_request, "Incorrect request/formdata"
  end

  swagger_api :update do |organization|
    notes "Permissions: Organization Admin"
    OrganizationsController::add_oraganization_params(organization)
    param :path, :id, :integer, :required, "Organization Id"
    response :success, "Updated organization record", :organization
    response :unauthorized, "You are unauthorized to access this page."
    response :bad_request, "Incorrect request/formdata"
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :destroy do
    notes "Permissions: Organization Admin"
    param :path, :id, :integer, :required, "Organization Id"
    response :success, "Organization destroyed successfully"
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  def index
    sortby  = params[:sortby] || ''
    sortdir = params[:sortdir] || ''
    @organizations = Organization.order("#{sortby} #{sortdir}").page(@page).per(@per_page) rescue []
    success_response(
      {
        organizations: @organizations.map(&:to_hash)
      }
    )
  end

  def create
    @organization = Organization.new(organization_params)
    @organization.created_by = current_user.id
    if @organization.save
      @organization.organization_users.create(
        user_id: current_user.id,
        user_type: ORG_USER_TYPE_ADMIN
      )
      success_response(
        {
          organization: @organization.to_hash
        }
      )
    else
      error_response(@organization.errors)
    end
  end

  def show
    success_response(
      {
        organization: @organization.to_hash
      }
    )
  end

  def update
    if @organization.update(organization_params)
      success_response(
        {
          organization: @organization.to_hash
        }
      )
    else
      error_response(@organization.errors)
    end
  end

  def destroy
    if @organization.destroy
      success_response(
        {
          message: "Organization destroyed successfully"
        }
      )
    else
      error_response(@organization.errors)
    end
  end

  private
  def set_organization
    @organization = Organization.find_by_id(params[:id])
    error_response(["Organization Not Found."]) if @organization.blank?
  end

  def organization_params
    params.require(:organization).permit(
      :name,
      :email_domain,
      :phone,
      :address,
      :created_by,
      :activated
    )
  end

  protected
  def ensure_params_exist
    if params[:organization].blank?
      error_response(["Organization related parameters not found."])
    end
  end
end
