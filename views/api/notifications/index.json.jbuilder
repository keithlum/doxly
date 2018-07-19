json.array!(@notifications) do |notification|
  json.extract! notification, :id, :user_id, :message, :status
  json.url notification_url(notification, format: :json)
end
