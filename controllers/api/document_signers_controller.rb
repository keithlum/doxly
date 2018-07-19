class Api::DocumentSignersController < ApplicationController
  respond_to :json

  before_action :authenticate_user!
  before_action :authenticate_document_owner!, only: [:create, :update, :destroy]
  before_action :ensure_params_exist, only: [:create, :update]
  before_action :set_document
  before_action :set_document_signer, only: [:show, :update, :destroy]

  swagger_controller :document_signer, "Document Signer"

  def self.add_document_signer_params(document_signer)
    document_signer.param :form, "document_signer[signed]", :boolean, :optional, "Signed"
  end

  swagger_api :index do
    notes "Permissions: Deal Collaborators"
    param :path, :document_id, :integer, :required, "Document Id"
    response :success, "List of document_signers records", :document_signer
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :show do
    notes "Permissions: Deal Collaborators"
    param :path, :document_id, :integer, :required, "Document Id"
    param :path, :id, :integer, :required, "Document Signer Id"
    response :success, "Document signer record", :document_signer
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :create do 
    notes "Permissions: Deal Admin and Document Owner"
    param :path, :document_id, :integer, :required, "Document Id"
    param :form, "document_signer[user_id]", :integer, :required, "User Id"
    response :success, "Document Signer updated successfully", :document_signer
    response :bad_request, "Incorrect request/formdata"
  end

  swagger_api :update do |document_signer|
    notes "Permissions: Deal Admin, Document Owner, the Signer User"
    DocumentSignersController::add_document_signer_params(document_signer)
    param :path, :id, :integer, :required, "Document Signer Id"
    param :path, :document_id, :integer, :required, "Document Id"
    response :success, "Document Signer updated successfully", :document_signer
    response :unauthorized, "You are unauthorized to access this page."
    response :bad_request, "Incorrect request/formdata"
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :destroy do
    notes "Permissions: Deal Admin and Document Owner who created the document"
    param :path, :id, :integer, :required, "Document Signer Id"
    param :path, :document_id, :integer, :required, "Document Id"
    response :success, "Document Signer destroyed successfully"
  end

  def index
    sortby  = params[:sortby] || ''
    sortdir = params[:sortdir] || ''
    @document_signers = @document.document_signers
                                 .order("#{sortby} #{sortdir}")
                                 .page(@page)
                                 .per(@per_page) rescue []
    success_response(
      {
        document_signers: @document_signers.map(&:to_hash)
      }
    )
  end

  def show
    success_response(
      {
        document_signer: @document_signer.to_hash
      }
    )
  end

  def create
    @document_signer = @document.document_signers.new(document_signer_params)
    if @document_signer.save
      success_response(["Document Signer created successfully."])
    else
      error_response(@document_signer.errors)
    end
  end

  def update
      @document_signer.signed_at = Time.now
    if @document_signer.update(document_signer_params)
      success_response(["Document Signer updated successfully"])
    else
      error_response(@document_signer.errors)
    end
  end

  def destroy
    if @document_signer.destroy
      success_response(["Document Signer destroyed successfully"])
    else
      error_response(@document_signer.errors)
    end
  end

  private
  def set_document
    @document = Document.find_by_id(params[:document_id])
    error_response(["Document Not Found"]) if @document.blank?
  end

  def set_document_signer
    @document_signer = @document.document_signers.find_by_id(params[:id])
    error_response(["Document Signer Not Found"]) if @document_signer.blank?
  end

  def document_signer_params
    params.require(:document_signer).permit(
      :document_id,
      :user_id,
      :signed,
      :signed_at
    )
  end

  protected
  def ensure_params_exist
    if params[:document_signer].blank?
      error_response(["Document Signer related parameters not found."])
    end
  end

  def authenticate_document_owner!
    if current_user.blank? or !current_user.is_document_owner?(params[:id])
      unauthorized_response
    end
  end

end
