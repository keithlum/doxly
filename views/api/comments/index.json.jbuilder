json.array!(@comments) do |comment|
  json.extract! comment, :id, :user_id, :deal_id, :task_id, :document_id, :comment
  json.url comment_url(comment, format: :json)
end
