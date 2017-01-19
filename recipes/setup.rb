
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
  prefs[:frontend] = multiple_choice "Front-end framework?", [["None", "none"],
    ["Bootstrap 4.0", "bootstrap4"],
    ["Zurb Foundation 5.5", "foundation5"],
    ["Simple CSS", "simple"]] unless prefs.has_key? :frontend
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
