json.array!(@documents) do |document|
  json.extract! document, :id, :file_name, :file_size, :file_type, :file_uploaded_at, :parent_type, :parent_id, :created_by, :activated
  json.url document_url(document, format: :json)
end
