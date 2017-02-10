# Be sure to restart your server when you modify this file.
# Read more: https://github.com/cyu/rack-cors

if ENV["WEB_HOST"].present? && (ENV['WEB_HOST'] != ENV['API_HOST'])
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins ENV["WEB_HOST"]
      resource "*", headers: :any, methods: :any
    end
  end
end
