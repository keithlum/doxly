json.array!(@sections) do |section|
  json.extract! section, :id, :name, :deal_id, :category_id, :created_id, :activated
  json.url section_url(section, format: :json)
end
