json.array!(@organization_users) do |organization_user|
  json.extract! organization_user, :id, :organization_id, :user_id, :user_type
  json.url organization_user_url(organization_user, format: :json)
end
