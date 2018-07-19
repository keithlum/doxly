json.array!(@folders) do |folder|
  json.extract! folder, :id, :name, :parent_type, :parent_id, :created_by, :activated
  json.url folder_url(folder, format: :json)
end
