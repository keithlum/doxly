class Api::NotificationsController < ApplicationController
  respond_to :json

  before_action :authenticate_user!
  before_action :authenticate_super_admin!, only: [:create, :destroy]
  before_action :authenticate_notification_reciever!, only: [:show, :update]
  before_action :set_notification, only: [:show, :update, :destroy]

  swagger_controller :notification, "Notification"

  def self.add_notification_params(notification)
    notification.param :form, "notification[user_ids]", :array, :required, "User"
    notification.param :form, "notification[message]", :string, :required, "Message"
  end

  swagger_api :index do
    notes "Permissions: Self User (logged in)"
    param :query, :user_id, :integer, :optional, "User Id"
    param :query, :status,  :string,  :optional, "Status"
    response :success, "List of notifications records", :notification
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :show do
    notes "Permissions: Super Admin, Notification Receiver"
    param :path, :id, :integer, :required, "Notification Id"
    response :success, "Notification record", :notification
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :create do |notification|
    notes "Permissions: Super Admin"
    NotificationsController::add_notification_params(notification)
    response :success, "Notification created successfully.", :notification
    response :bad_request, "Incorrect request/formdata"
  end

  swagger_api :update do |notification|
    notes "Permissions: Notification Receiver"
    param :path, :id, :integer, :required, "Notification Id"
    param :form, "notification[status]", :string, :optional, "Status"
    response :success, "Notification updated successfully", :notification
    response :unauthorized, "You are unauthorized to access this page."
    response :bad_request, "Incorrect request/formdata"
    response :forbidden, "You are unauthorized User"
  end

  swagger_api :destroy do
    notes "Permissions: Super Admin"
    param :path, :id, :integer, :required, "Notification Id"
    response :success, "Notification destroyed successfully"
    response :unauthorized, "You are unauthorized to access this page."
    response :forbidden, "You are unauthorized User"
  end

  def index
    sortby  = params[:sortby] || ''
    sortdir = params[:sortdir] || ''
    user_id = params[:user_id] || current_user.id
    status  = params[:status]
    conditions  = []
    conditions << ["status = ?", "#{status.downcase}"] if status and status.to_s != 'all'
    conditions << ["user_id = ?", "#{user_id}"] if user_id
    @notifications = Notification.where(conditions[0])
                       .order("#{sortby} #{sortdir}")
                       .page(@page)
                       .per(@per_page) rescue []
    success_response(
      {
        notifications: @notifications.map(&:to_hash)
      }
    )
  end

  def show
    success_response(
      {
        notification: @notification.to_hash
      }
    )
  end

  def create
    if params[:notification] and params[:notification][:user_ids] and params[:notification][:message]
      params[:notification][:user_ids].each do |user_id|
        @notification = Notification.new(
                          message: params[:notification][:message],
                          user_id: user_id,
                          status: 'unread'
                        )
        @notification.save
      end
      success_response(["Notification created successfully."])
    else
      error_response(["Notification related parameters not found."])
    end
  end

  def update
    if params[:notification][:status] and @notification.update(status: params[:notification][:status])
      success_response(["Notification updated successfully"])
    else
      error_response(["Notification status related parameters not found."])
    end
  end

  def destroy
    if @notification.destroy
      success_response(["Notification destroyed successfully"])
    else
      error_response(@notification.errors)
    end
  end

  private
  def set_notification
    @notification = Notification.find_by_id(params[:id])
    error_response(["Notification Not Found"]) if @notification.blank?
  end

   def authenticate_notification_reciever!
    if current_user.blank? or !current_user.is_notification_reciever?(params[:id])
      unauthorized_response
    end
  end
end
