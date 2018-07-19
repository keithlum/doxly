json.array!(@deal_collaborators) do |deal_collaborator|
  json.extract! deal_collaborator, :id, :deal_id, :user_id, :added_by
  json.url deal_collaborator_url(deal_collaborator, format: :json)
end
