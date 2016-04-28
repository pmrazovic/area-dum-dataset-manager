json.array!(@section_configurations) do |section_configuration|
  json.extract! section_configuration, :id
  json.url section_configuration_url(section_configuration, format: :json)
end
