json.array!(@deals) do |deal|
  json.extract! deal, :id, :organization_id, :title, :client_name, :transaction_type, :deal_size, :projected_close_date, :completion_percent, :status, :admin_user_id, :activated
  json.url deal_url(deal, format: :json)
end
