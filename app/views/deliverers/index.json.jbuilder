json.array!(@deliverers) do |deliverer|
  json.extract! deliverer, :id
  json.url deliverer_url(deliverer, format: :json)
end
