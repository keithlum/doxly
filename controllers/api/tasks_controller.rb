class Api::TasksController < ApplicationController
  respond_to :json

  before_action :authenticate_user!
  before_action :ensure_params_exist, only: [:create, :update]
  before_action :set_task, only: [:show, :update, :destroy]
  before_action :is_deal_collaborator?, only: [:update, :destroy, :show, :create]

  swagger_controller :task, "Task"

  def self.add_task_params(task)
    task.param :form, "task[title]", :string, :required, "Title"
    task.param :form, "task[description]", :string, :optional, "Description"
    task.param :form, "task[status]", :string, :optional, "Status"
    task.param :form, "task[assignee_id]", :integer, :optional, "Assignee Id"
    task.param :form, "task[organization_id]", :integer, :required, "Organization Id"
    task.param :form, "task[deal_id]", :integer, :required, "Deal Id"
    task.param :form, "task[due_date]", :datetime, :optional, "Due Date"
  end

  swagger_api :index do
    notes "Permissions: Deal Collaborators"
    param :query, :org_id, :integer, :optional, "Organization Id"
    param :query, :deal_id, :integer, :optional, "Deal Id"
    param :query, :section_id, :integer, :optional, "Section Id"
    param :query, :assignee_id, :integer, :optional, "Assignee Id"
    response :success, "List of task record", :task
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :show do
    notes "Permissions: Deal Collaborators"
    param :path, :id, :integer, :required, "Task Id"
    response :success, "Task record", :task
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :create do |task|
    notes "Permissions: Deal Collaborators"
    TasksController::add_task_params(task)
    param :form, "task[section_id]", :integer, :required, "Section Id"
    response :success, "Task created successfully.", :task
    response :bad_request, "Incorrect request/formdata"
  end

  swagger_api :update do |task|
    notes "Permissions: Deal Collaborators"
    TasksController::add_task_params(task)
    param :path, :id, :integer, :required, "Task Id"
    response :success, "Task updated successfully", :task
    response :unauthorized, "You are unauthorized to access this page."
    response :bad_request, "Incorrect request/formdata"
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :destroy do
    notes "Permissions: Deal Admin and Task Owner"
    param :path, :id, :integer, :required, "Task Id"
    response :success, "Task destroyed successfully"
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  def index
    sortby      = params[:sortby] || ''
    sortdir     = params[:sortdir] || ''
    @org_id     = params[:org_id]
    @deal_id    = params[:deal_id]
    @section_id = params[:section_id]
    @assignee_id = params[:assignee_id]

    conditions  = []
    conditions[0] = ["section_id = ?", "#{@section_id}"] if @section_id
    conditions[0] = ["assignee_id = ?", "#{@assignee_id}"] if @assignee_id
    conditions[0] = ["organization_id = ?", "#{@org_id}"] if @org_id
    conditions[0] = ["deal_id = ?", "#{@deal_id}"] if @deal_id

    @tasks = current_user.tasks
                         .where(conditions[0])
                         .order("#{sortby} #{sortdir}")
                         .page(@page)
                         .per(@per_page) rescue []
    success_response(
      {
        tasks: @tasks.map(&:to_hash)
      }
    )
  end

  def create
    @task = Task.new(task_params)
    @task.created_by = current_user.id
    if @task.save
      success_response(
        {
          task: @task.to_hash
        }
      )
    else
      error_response(@task.errors)
    end
  end

  def update
    if @task.update(task_params)
      success_response(["Task updated successfully"])
    else
      error_response(@task.errors)
    end
  end

  def show
    success_response(
      {
        task: @task.to_hash
      }
    )
  end

  def destroy
    if @task.destroy
      success_response(["Task destroyed successfully"])
    else
      error_response(@task.errors)
    end
  end

  private
  def set_task
    @task = Task.find_by_id(params[:id])
    error_response(["Task Not Found."]) if @task.blank?
  end

  def is_deal_collaborator?
    if @task.blank?
      @section = Section.find_by_id(params[:task][:section_id])
      @deal = @section.deal if @section
    else
      @deal = @task.section.deal
    end

    if !@deal.blank?
      return current_user.is_deal_collaborator?(@deal.id)
    else
      error_response(["Deal Not Found for this task."])
    end
  end

  def task_params
    params.require(:task).permit(
      :organization_id,
      :deal_id,
      :title,
      :description,
      :status,
      :section_id,
      :assignee_id,
      :created_by,
      :due_date
    )
  end

  protected
  def ensure_params_exist
    if params[:task].blank?
      error_response(["Task related parameters not found."])
    end
  end
end
