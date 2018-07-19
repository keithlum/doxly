class Api::DealsController < ApplicationController
  respond_to :json

  before_action :authenticate_user!
  before_action :authenticate_organization_member!, only: [:create]
  before_action :authenticate_org_deal_admin!, only: [:update, :destroy]
  before_action :authenticate_deal_collaborator!, only: [:show]
  before_action :ensure_params_exist, only: [:create, :update]
  before_action :set_deal, only: [:update, :destroy, :show]

  swagger_controller :deal, "deal"

  def self.add_deal_params(deal)
    deal.param :form, "deal[title]", :string, :required, "Title"
    deal.param :form, "deal[client_name]", :string, :required, "Client Name"
    deal.param :form, "deal[transaction_type]", :string, :required, "Transaction Type"
    deal.param :form, "deal[deal_size]", :string, :optional, "Deal Size"
    deal.param :form, "deal[projected_close_date]", :date, :optional, "Projected Close Date"
    deal.param :form, "deal[completion_percent]", :float, :optional, "Completion Percent"
    deal.param :form, "deal[status]", :string, :required, "Status"
    deal.param :form, "deal[activated]", :boolean, :optional, "Activated"
  end

  swagger_api :index do
    notes "Permissions: Organization Member"
    param :query, :organization_id, :integer, :optional, "Organization Id"
    response :success, "List of accessible deal records", :deal
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :show do
    notes "Permissions: Deal Collaborators"
    param :path, :id, :integer, :required, "deal Id"
    response :success, "Deal record", :deal
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :create do |deal|
    notes "Permissions: Organization Member"
    DealsController::add_deal_params(deal)
    param :form, "deal[organization_id]", :integer, :required, "Organization Id"
    response :success, "Deal created successfully.", :deal
    response :bad_request, "Incorrect request/formdata"
  end

  swagger_api :update do |deal|
    notes "Permissions: Deal Admin, Organization Admin"
    DealsController::add_deal_params(deal)
    param :path, :id, :integer, :required, "deal Id"
    response :success, "Deal updated successfully", :deal
    response :unauthorized, "You are unauthorized to access this page."
    response :bad_request, "Incorrect request/formdata"
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :destroy do
    notes "Permissions: Deal Admin, Organization Admin"
    param :path, :id, :integer, :required, "deal Id"
    response :success, "Deal destroyed successfully"
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  def index
    sortby  = params[:sortby] || ''
    sortdir = params[:sortdir] || ''
    org_id  = params[:organization_id]
    conditions  = []
    conditions << ["organization_id = ?", "#{org_id}"] if org_id
    if current_user.is_super?
      @deals = Deal.where(conditions[0])
                   .order("#{sortby} #{sortdir}")
                   .page(@page)
                   .per(@per_page) rescue []
    elsif current_user.is_organization_admin?(current_user.organization.try(:id))
      @deals = current_user.organization
                           .deals
                           .where(conditions[0])
                           .order("#{sortby} #{sortdir}")
                           .page(@page)
                           .per(@per_page) rescue []
    else
      @deals = current_user.deals
                           .where(conditions[0])
                           .order("#{sortby} #{sortdir}")
                           .page(@page)
                           .per(@per_page) rescue []
    end
    success_response(
      {
        deals: @deals.map(&:to_hash)
      }
    )
  end

  def create
    @deal = Deal.new(deal_params)
    @deal.admin_user_id = current_user.id
    if @deal.save
      success_response(
        {
          deal: @deal.to_hash,
          redirect_to: app_deal_path(@deal)
        }
      )
    else
      error_response(@deal.errors)
    end
  end

  def update
    if @deal.update(deal_params)
      success_response(
      {
        deal: @deal.to_hash,
        redirect_to: app_deal_path(@deal)
      }
    )
    else
      error_response(@deal.errors)
    end
  end

  def show
    success_response(
      {
        deal: @deal.to_hash
      }
    )
  end

  def destroy
    if @deal.destroy
      success_response(["Deal destroyed successfully"])
    else
      error_response(@deal.errors)
    end
  end

  private
  def set_deal
    @deal = Deal.find_by_id(params[:id])
    error_response(["Deal Not Found"]) if @deal.blank?
  end

  def deal_params
    params.require(:deal).permit(
      :organization_id,
      :title,
      :client_name,
      :transaction_type,
      :deal_size,
      :projected_close_date,
      :status,
      :activated
    )
  end

  protected
  def ensure_params_exist
    if params[:deal].blank?
      error_response(["Deal related parameters not found."])
    end
  end
end
