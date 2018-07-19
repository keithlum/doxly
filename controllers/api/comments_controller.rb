class Api::CommentsController < ApplicationController
  respond_to :json

  before_action :authenticate_user!
  before_action :ensure_params_exist, only: [:create, :update]
  before_action :set_comment, only: [:show, :update, :destroy]
  before_action :is_deal_collaborator?, only: [:update, :destroy, :show, :create]

  swagger_controller :comment, "Comment"

  def self.add_comment_params(comment)
    comment.param :form, "comment[user_id]", :integer, :required, "User Id"
    comment.param :form, "comment[task_id]", :integer, :required, "Task Id"
    comment.param :form, "comment[document_id]", :integer, :optional, "Document Id"
    comment.param :form, "comment[comment_type]", :string, :required, "Comment Type"
    comment.param :form, "comment[comment]", :text, :required, "Comment"
  end

  swagger_api :index do
    notes "Permissions: Deal Collaborators"
    param :query, :document_id, :integer, :optional, "Document Id"
    param :query, :deal_id, :integer, :optional, "Deal Id"
    param :query, :user_id, :integer, :optional, "User Id"
    param :query, :task_id, :integer, :optional, "Task Id"
    param :query, :comment_type, :string, :optional, "Comment Type"
    response :success, "List of comments records", :comment
    response :unauthorized, "You are unauthorized to access this page."
  end

  swagger_api :show do
    notes "Permissions: Deal Collaborators"
    param :path, :id, :integer, :required, "Comment Id"
    response :success, "Document record", :comment
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :create do |comment|
    notes "Permissions: Deal Collaborators"
    CommentsController::add_comment_params(comment)
    response :success, "Comment created successfully.", :comment
    response :bad_request, "Incorrect request/formdata"
  end

  swagger_api :update do
    notes "Permissions: Deal Admin and Comment Owner who wrote the comment"
    param :path, :id, :integer, :required, "Comment Id"
    param :form, "comment[comment]", :text, :optional, "Comment"
    response :success, "Comment updated successfully", :comment
    response :unauthorized, "You are unauthorized to access this page."
    response :bad_request, "Incorrect request/formdata"
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :destroy do
    notes "Permissions: Deal Admin and Comment Owner who wrote the comment"
    param :path, :id, :integer, :required, "Comment Id"
    response :success, "Comment destroyed successfully"
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  def index
    sortby       = params[:sortby] || ''
    sortdir      = params[:sortdir] || ''
    # deal_id      = params[:deal_id]
    task_id      = params[:task_id]
    document_id  = params[:document_id]
    user_id      = params[:user_id] || current_user.id
    comment_type = params[:comment_type]
    conditions  = []
    conditions << ["task_id = ?", "#{task_id}"] if task_id
    conditions << ["user_id = ?", "#{user_id}"] if user_id
    conditions << ["document_id = ?", "#{document_id}"] if document_id
    conditions << ["comment_type = ?", "#{comment_type}"] if comment_type

    @comments = Comment.where(conditions[0])
                       .order("#{sortby} #{sortdir}")
                       .page(@page)
                       .per(@per_page) rescue []
    success_response(
      {
        comments: @comments.map(&:to_hash)
      }
    )
  end

  def create
    @comment = Comment.new(comment_params)
    if @comment.save
      success_response(["Comment created successfully."])
    else
      error_response(@comment.errors)
    end
  end

  def show
    success_response(
      {
        comment: @comment.to_hash
      }
    )
  end

  def update
    if @comment.update(comment_params)
      success_response(["Comment updated successfully"])
    else
      error_response(@comment.errors)
    end
  end

  def destroy
    if @comment.destroy
      success_response(["Comment destroyed successfully"])
    else
      error_response(@comment.errors)
    end
  end

  private
  def set_comment
    @comment = Comment.find_by_id(params[:id])
    error_response(["Comment Not Found"]) if @comment.blank?
  end

  def comment_params
    params.require(:comment).permit(
      :user_id,
      :deal_id,
      :task_id,
      :document_id,
      :comment_type,
      :comment
    )
  end

  def is_deal_collaborator?
    if @comment.blank?
      @task = Task.find_by_id(params[:comment][:task_id])
      @section = @task.section if @task
      @deal = @section.deal if @section
    else
      @deal = @comment.task.section.deal
    end

    if !@deal.blank?
      return if current_user.is_deal_collaborator?(@deal.id) or
                current_user.is_org_deal_admin?(@deal.id) or
                current_user.is_comment_owner?(@comment.id)
    else
      error_response(["Deal Not Found for this Comment."])
    end
  end

  protected
  def ensure_params_exist
    if params[:comment].blank?
      error_response(["Comment related parameters not found."])
    end
  end
end
