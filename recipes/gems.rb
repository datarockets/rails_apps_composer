# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/gems.rb

### GEMFILE ###

## Cleanup
# remove the 'sdoc' gem
if Rails::VERSION::MAJOR == 4 && Rails::VERSION::MINOR >= 2
  gsub_file 'Gemfile', /gem 'sdoc',\s+'~> 0.4.0',\s+group: :doc/, ''
else
  gsub_file 'Gemfile', /group :doc do/, ''
  gsub_file 'Gemfile', /\s*gem 'sdoc', require: false\nend/, ''
end

## Web Server
if (prefs[:dev_webserver] == prefs[:prod_webserver])
  add_gem 'thin' if prefer :dev_webserver, 'thin'
  add_gem 'unicorn' if prefer :dev_webserver, 'unicorn'
  add_gem 'unicorn-rails' if prefer :dev_webserver, 'unicorn'
else
  add_gem 'thin', group: [:development, :test] if prefer :dev_webserver, 'thin'
  add_gem 'unicorn', group: [:development, :test] if prefer :dev_webserver, 'unicorn'
  add_gem 'unicorn-rails', group: [:development, :test] if prefer :dev_webserver, 'unicorn'
  add_gem 'thin', group: :production if prefer :prod_webserver, 'thin'
  add_gem 'unicorn', group: :production if prefer :prod_webserver, 'unicorn'
end

## Database Adapter
gsub_file 'Gemfile', /gem 'sqlite3'\n/, '' unless prefer :database, 'sqlite'
gsub_file 'Gemfile', /gem 'pg'.*/, ''
add_gem 'pg', '~> 0.18' if prefer :database, 'postgresql'

## Gem to set up controllers, views, and routing in the 'apps4' recipe
# add_gem 'rails_apps_pages', :group => :development if prefs[:apps4] TESTED

## Template Engine
if prefer :templates, 'slim'
  add_gem 'slim-rails'
  add_gem 'html2slim', group: :development
end

## Testing Framework
if prefer :tests, 'rspec'
  add_gem 'rails_apps_testing', group: :development
  add_gem 'rspec-rails', group: [:development, :test]
  add_gem 'spring-commands-rspec', group: :development unless prefer :apps4, 'rails-datarockets-api'
  add_gem 'factory_girl_rails', group: [:development, :test]
  add_gem 'faker', group: [:development, :test]
  add_gem 'capybara', group: :test if prefs[:capybara]
  add_gem 'shoulda-matchers', group: :test
  add_gem 'database_cleaner', group: :test
  add_gem 'webmock', group: :test
  add_gem 'simplecov', group: :test, require: false
  if prefer :continuous_testing, 'guard'
    add_gem 'guard-bundler', group: :development
    add_gem 'guard-rails', group: :development
    add_gem 'guard-rspec', group: :development
    add_gem 'rb-inotify', group: :development, require: false
    add_gem 'rb-fsevent', group: :development, require: false
    add_gem 'rb-fchange', group: :development, require: false
  end
end

## Authentication (Devise)
if prefer :authentication, 'devise'
    add_gem 'devise'
    add_gem 'devise_invitable' if prefer :devise_modules, 'invitable'
end

## Authentication (OmniAuth)
add_gem 'omniauth' if prefer :authentication, 'omniauth'
add_gem 'omniauth-twitter' if prefer :omniauth_provider, 'twitter'
add_gem 'omniauth-facebook' if prefer :omniauth_provider, 'facebook'
add_gem 'omniauth-github' if prefer :omniauth_provider, 'github'
add_gem 'omniauth-linkedin' if prefer :omniauth_provider, 'linkedin'
add_gem 'omniauth-google-oauth2' if prefer :omniauth_provider, 'google_oauth2'
add_gem 'omniauth-tumblr' if prefer :omniauth_provider, 'tumblr'

## Authorization
add_gem 'pundit' if prefer :authorization, 'pundit'

## Form Builder
add_gem 'simple_form' if prefer :form_builder, 'simple_form'

## Gems from a defaults file or added interactively
gems.each do |g|
  add_gem(*g)
end

add_gem 'seedbank'
create_file 'db/seeds/development/.keep', ''
create_file 'db/seeds/production/.keep', ''
create_file 'db/seeds/staging/.keep', ''

git :add => '-A' if prefer :git, true
git :commit => '-qm "rails_apps_composer: Gemfile"' if prefer :git, true

### CREATE DATABASE ###
stage_two do
  say_wizard "recipe stage two"
  say_wizard "configuring database"
  run "erb2slim 'app/views' -d" if prefer :templates, 'slim'

  if prefs[:cors] || yes_wizard?("Use rack-cors?")
    add_gem 'rack-cors', require: 'rack/cors'
    copy_from_file 'initializers/cors.rb', 'config/initializers/cors.rb'
  end

  unless prefer :database, 'sqlite'
    copy_from_repo 'config/database-postgresql.yml', :prefs => 'postgresql'
    if prefer :database, 'postgresql'
      begin
        copy_from_file 'database.yml', 'config/database.yml'

        pg_username = prefs[:pg_username] || ask_wizard("Username for PostgreSQL?(leave blank to use the app name)")
        pg_host = prefs[:pg_host] || ask_wizard("Host for PostgreSQL in database.yml? (leave blank to use default socket connection)")
        if pg_username.blank?
          say_wizard "Creating a user named '#{app_name}' for PostgreSQL"
          run "createuser --createdb #{app_name}" if prefer :database, 'postgresql'
          gsub_file "config/database.yml", /username: .*/, "username: #{app_name}"
        else
          gsub_file "config/database.yml", /username: .*/, "username: #{pg_username}"
          pg_password = prefs[:pg_password] || ask_wizard("Password for PostgreSQL user #{pg_username}?")
          gsub_file "config/database.yml", /password: .*\n/, "password: #{pg_password}\n"
          say_wizard "set config/database.yml for username/password #{pg_username}/#{pg_password}"
        end
        if pg_host.present?
          gsub_file "config/database.yml", /  host:     localhost/, "  host:     #{pg_host}"
        end
      rescue StandardError => e
        raise "unable to create a user for PostgreSQL, reason: #{e}"
      end
      gsub_file "config/database.yml", /database: myapp_development/, "database: #{app_name}_development"
      gsub_file "config/database.yml", /database: myapp_test/,        "database: #{app_name}_test"
      gsub_file "config/database.yml", /database: myapp_production/,  "database: #{app_name}_production"
    end

    unless prefer :database, 'sqlite'
      if (prefs.has_key? :drop_database) ? prefs[:drop_database] :
          (yes_wizard? "Okay to drop all existing databases named #{app_name}? 'No' will abort immediately!")
        run 'bundle exec rake db:drop'
      else
        raise "aborted at user's request"
      end
    end
    run 'bundle exec rake db:create:all'
    ## Git
    git :add => '-A' if prefer :git, true
    git :commit => '-qm "rails_apps_composer: create database"' if prefer :git, true
  end
end

### GENERATORS ###
stage_two do
  say_wizard "recipe stage two"
  say_wizard "running generators"

  ## Form
  prefs[:forms] = yes_wizard? "Use Reform form?" unless prefs.has_key? :forms
  if prefer :forms, true
    add_gem 'reform-rails', '~> 0.1'
    add_gem 'virtus'
    create_file 'app/forms/.keep', ''
  end

  ## Form Builder
  if prefer :form_builder, 'simple_form'
    case prefs[:frontend]
      when 'bootstrap4'
        say_wizard "simple_form not yet available for use with Bootstrap 4"
      when 'foundation6'
        say_wizard "recipe installing simple_form for use with Zurb Foundation"
        generate 'simple_form:install --foundation'
      else
        say_wizard "recipe installing simple_form"
        generate 'simple_form:install'
    end
  end
  ## Figaro Gem
  if prefer :local_env_file, 'figaro'
    run 'figaro install'
    gsub_file 'config/application.yml', /# PUSHER_.*\n/, ''
    gsub_file 'config/application.yml', /# STRIPE_.*\n/, ''
    prepend_to_file 'config/application.yml' do <<-FILE
# Add account credentials and API keys here.
# See http://railsapps.github.io/rails-environment-variables.html
# This file should be listed in .gitignore to keep your settings secret!
# Each entry sets a local environment variable.
# For example, setting:
# GMAIL_USERNAME: Your_Gmail_Username
# makes 'Your_Gmail_Username' available as ENV["GMAIL_USERNAME"]

FILE
    end
  end

  ## Git
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: generators"' if prefer :git, true
end

__END__

name: gems
description: "Add the gems your application needs."
author: RailsApps

requires: [setup]
run_after: [setup]
category: configuration
