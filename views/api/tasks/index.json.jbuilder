json.array!(@tasks) do |task|
  json.extract! task, :id, :title, :description, :status, :section_id, :assignee_id, :created_by, :due_date
  json.url task_url(task, format: :json)
end
