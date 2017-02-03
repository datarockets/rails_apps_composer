Apipie.configure do |config|
  config.app_name = "myapp" # should be real app name
  config.validate = false
  config.process_params = false
  config.api_base_url = "/api"
  config.doc_base_url = "/apidoc"
  config.namespaced_resources = true

  config.api_controllers_matcher = "#{Rails.root}/app/controllers/api/**/*.rb"
end
