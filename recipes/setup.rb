## Application configs
insert_code = '
      g.stylesheets = false
      g.javascripts = false
      g.helper = false
'
inject_into_file 'config/application.rb', insert_code, after: "config.generators do |g|\n"

## Ruby on Rails
HOST_OS = RbConfig::CONFIG['host_os']
say_wizard "Your operating system is #{HOST_OS}."
say_wizard "You are using Ruby version #{RUBY_VERSION}."
say_wizard "You are using Rails version #{Rails::VERSION::STRING}."

## Is sqlite3 in the Gemfile?
gemfile = File.read(destination_root() + '/Gemfile')
sqlite_detected = gemfile.include? 'sqlite3'

## Web Server
prefs[:dev_webserver] = multiple_choice "Web server for development?", [["Puma (default)", "puma"],
  ["Thin", "thin"], ["Unicorn", "unicorn"]] unless prefs.has_key? :dev_webserver
prefs[:prod_webserver] = multiple_choice "Web server for production?", [["Puma (default)", "puma"],
  ["Thin", "thin"], ["Unicorn", "unicorn"]] unless prefs.has_key? :prod_webserver

## Database Adapter
prefs[:database] = "sqlite" if prefer :database, 'default'
prefs[:database] = multiple_choice "Database used in development?", [["SQLite", "sqlite"], ["PostgreSQL", "postgresql"],
  ] unless prefs.has_key? :database

## Template Engine
prefs[:templates] = multiple_choice "Template engine?", [["ERB", "erb"], ["Slim", "slim"]] unless prefs.has_key? :templates

## Testing Framework
if recipes.include? 'tests'
  prefs[:tests] = multiple_choice "Test framework?", [["None", "none"], ["RSpec", "rspec"]] unless prefs.has_key? :tests
  if prefs[:tests] == 'rspec'
    prefs[:capybara] = yes_wizard? "Use Capybara?" unless prefs.has_key? :capybara
    say_wizard "Adding DatabaseCleaner, FactoryGirl, Faker"
    prefs[:continuous_testing] = multiple_choice "Continuous testing?", [["None", "none"], ["Guard", "guard"]] unless prefs.has_key? :continuous_testing
  end
end

## Front-end Framework
if recipes.include? 'frontend'
  prefs[:npm] = multiple_choice "Packege manager for install frontend path", [["Default", "none"], ["NPM", "npm"]] unless prefs.has_key? :npm
  prefs[:frontend] = multiple_choice "Front-end framework?", [["None", "none"],
    ["Bootstrap 4.0", "bootstrap4"],
    ["Zurb Foundation 6", "foundation6"],
    ["Simple CSS", "simple"]] if (prefs[:npm] == 'none' && prefs.has_key?(:frontend))
end

## Add yrn
prefs[:yarn] = yes_wizard?("Use yarn?") if prefs[:yarn].nil?
if prefs[:yarn]
  run 'brew install yarn'
  run 'yarn init'
end

## Email
if recipes.include? 'email'
  unless prefs.has_key? :email
    say_wizard "The Devise 'forgot password' feature requires email." if prefer :authentication, 'devise'
    prefs[:email] = multiple_choice "Add support for sending email?", [["None", "none"], ["Gmail","gmail"], ["SMTP","smtp"],
      ["SendGrid","sendgrid"], ["Mandrill","mandrill"]]
  end
else
  prefs[:email] = 'none'
end

## Rollbar
prefs[:rollbar] = yes_wizard?("Use rollbar?") if prefs[:rollbar].nil?
if prefs[:rollbar]
  add_gem 'rollbar'
  rollbar_token = ask_wizard("Rollbar token:")
  run "rails generate rollbar #{rollbar_token}"
end

## Authentication and Authorization
if (recipes.include? 'devise') || (recipes.include? 'omniauth')
  prefs[:authentication] = multiple_choice "Authentication?", [["None", "none"], ["Devise", "devise"], ["OmniAuth", "omniauth"]] unless prefs.has_key? :authentication
  case prefs[:authentication]
    when 'devise'
      prefs[:devise_modules] = multiple_choice "Devise modules?", [["Devise with default modules","default"],
      ["Devise with Confirmable module","confirmable"],
      ["Devise with Confirmable and Invitable modules","invitable"]] unless prefs.has_key? :devise_modules
    when 'omniauth'
      prefs[:omniauth_provider] = multiple_choice "OmniAuth provider?", [["Facebook", "facebook"], ["Twitter", "twitter"], ["GitHub", "github"],
        ["LinkedIn", "linkedin"], ["Google-Oauth-2", "google_oauth2"], ["Tumblr", "tumblr"]] unless prefs.has_key? :omniauth_provider
  end
  prefs[:authorization] = multiple_choice "Authorization?", [["None", "none"], ["Simple role-based", "roles"], ["Pundit", "pundit"]] unless prefs.has_key? :authorization
end

## Form Builder
## (no simple_form for Bootstrap 4 yet)
unless prefs[:frontend] == 'bootstrap4'
  prefs[:form_builder] = multiple_choice "Use a form builder gem?", [["None", "none"], ["SimpleForm", "simple_form"]] unless prefs.has_key? :form_builder
end

__END__

name: setup
description: "Make choices for your application."
author: RailsApps

run_after: [git, railsapps]
category: configuration
