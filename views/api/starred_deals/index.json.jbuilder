json.array!(@starred_deals) do |starred_deal|
  json.extract! starred_deal, :id, :user_id, :deal_id
  json.url starred_deal_url(starred_deal, format: :json)
end
