class Api::StarredDealsController < ApplicationController
  respond_to :json

  before_action :authenticate_deal_collaborator!, only: [:index, :create, :destroy]
  before_action :authenticate_organization_member!, only: [:starred_deals]
  before_action :ensure_params_exist, only: [:create, :update]
  before_action :set_deal, except: [:starred_deals]
  before_action :set_starred_deal, only: [:destroy]

  swagger_controller :starred_deal, "starred_deal"

  def self.add_starred_deal_params(starred_deal)
    starred_deal.param :form, "starred_deal[user_id]", :string, :required, "User Id"
    starred_deal.param :form, "starred_deal[deal_id]", :string, :required, "Deal Id"
  end

  swagger_api :starred_deals do
    notes "Permissions: Organization Member"
    param :query, :organization_id, :integer, :optional, "Organization Id"
    response :success, "List of starred_deals records for user", :starred_deal
    response :unauthorized, "You are unauthorized to access this page."
    response :not_acceptable, "Error with your login or password"
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :index do
    notes "Permissions: Organization Member"
    param :path, :deal_id, :integer, :required, "Deal Id"
    response :success, "List of starred_deals records for user", :starred_deal
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :create do |starred_deal|
    notes "Permissions: Deal Collaborators"
    StarredDealsController::add_starred_deal_params(starred_deal)
    param :path, :deal_id, :integer, :required, "Deal Id"
    response :success, "Starred Deal created successfully.", :starred_deal
    response :bad_request, "Incorrect request/formdata"
  end

  swagger_api :destroy do
    notes "Permissions: Deal Collaborators"
    param :path, :deal_id, :integer, :required, "Deal Id"
    param :path, :id, :integer, :required, "Starred Deal Id"
    response :success, "Starred Deal destroyed successfully"
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  def index
    sortby  = params[:sortby] || ''
    sortdir = params[:sortdir] || ''

    deal_ids = current_user.deals.pluck(:id)

    @starred_deals = current_user.starred_deals
                                 .where("deal_id in (?)", deal_ids)
                                 .order("#{sortby} #{sortdir}")
                                 .page(@page).per(@per_page) rescue []
    success_response(
      {
        starred_deals: @starred_deals.map(&:to_hash)
      }
    )
  end

  def create
    @starred_deal = StarredDeal.new(starred_deal_params)
    if @starred_deal.save
      deal = @starred_deal.deal
      success_response({
        message: "Starred Deal added successfully",
        id: deal.id,
        title: deal.title,
        url: app_deal_path(deal)
      })
    else
      error_response(@starred_deal.errors)
    end
  end

  def destroy
    deal = @starred_deal.deal
    if @starred_deal.destroy
      success_response({
        message: "Starred Deal removed successfully",
        id: deal.id,
        title: deal.title,
        url: app_deal_path(deal)
      })
    else
      error_response(@starred_deal.errors)
    end
    return
  end

  def starred_deals
    sortby  = params[:sortby] || ''
    sortdir = params[:sortdir] || ''
    org_id  = params[:organization_id]
    conditions  = []
    conditions << ["organization_id = ?", "#{org_id}"] if org_id
    deal_ids = current_user.deals.where(conditions[0]).pluck(:id)

    @starred_deals = current_user.starred_deals
                                 .where("deal_id in (?)", deal_ids)
                                 .order("#{sortby} #{sortdir}")
                                 .page(@page).per(@per_page) rescue []
    success_response(
      {
        starred_deals: @starred_deals.map(&:to_hash)
      }
    )
  end

  private
  def set_deal
    @deal = Deal.find_by_id(params[:deal_id] || params[:starred_deal][:deal_id])
    error_response(["Deal Not Found."]) if @deal.blank?
  end

  def set_starred_deal
    if params[:id]
      @starred_deal = @deal.starred_deals.find_by_id(params[:id])
    elsif (params[:starred_deal])
      @starred_deal = StarredDeal.where(user_id: params[:starred_deal][:user_id], deal_id: params[:starred_deal][:deal_id]).try(:first)
    end
    error_response("Starred Deal Not Found") if @starred_deal.blank?
  end

  def starred_deal_params
    params.require(:starred_deal).permit(:user_id, :deal_id)
  end

  protected
  def ensure_params_exist
    if params[:starred_deal].blank?
      error_response(["Starred Deal related parameters not found."])
    end
  end
end
