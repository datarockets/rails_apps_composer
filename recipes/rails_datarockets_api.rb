
prefs[:apps4] = 'rails-datarockets-api'
# prefs[:github] = true
prefs[:frontend] = 'none'
prefs[:doc] = 'apipie'
prefs[:analytics] = 'none'
prefs[:email] = 'smtp'
prefs[:capybara] = false
prefs[:templates] = 'erb'
prefs[:continuous_testing] = 'none'
prefs[:tests] = 'rspec'
prefs[:deployment] = 'capistrano3'
prefs[:authentication] = 'none'
prefs[:authorization] = 'none'
prefs[:better_errors] = true
prefs[:form_builder] = 'none'
prefs[:git] = true
prefs[:circle_ci] = true
prefs[:pry] = true
prefs[:forms] = true
prefs[:disable_turbolinks] = true
prefs[:rubocop] = true
prefs[:rvmrc] = true
prefs[:dev_webserver] = 'puma'
prefs[:prod_webserver] = 'puma'
prefs[:database] = 'postgresql'

gsub_file 'Gemfile', /.*gem 'uglifier'.*\n/, ''
gsub_file 'Gemfile', /.*gem 'sass-rails'.*\n/, ''
gsub_file 'Gemfile', /.*gem 'coffee-rails'.*\n/, ''
gsub_file 'Gemfile', /.*gem 'jquery-rails'.*\n/, ''
gsub_file 'Gemfile', /.*gem 'turbolinks'.*\n/, ''
gsub_file 'Gemfile', /.*gem 'tzinfo-data'.*\n/, ''

%w(helpers assets).each do |folder_name|
  remove_dir "app/#{folder_name}"
end

%w(public/404.html public/500.html public/422.html config/initializers/assets.rb).each do |file_name|
  remove_file file_name
end

insert_into_file('config/application.rb', 'config.api_only = true',
  after: /class Application < Rails::Application.*\n/, force: false)

copy_from_file "initializers/jbuilder.rb", 'config/initializers/jbuilder.rb'

gsub_file 'app/controllers/application_controller.rb', /.*protect_from_forgery with: :exception.*\n/, ''

  # gems
  # add_gem 'gibbon'

  # stage_three do
  #   say_wizard "recipe stage three"
    # repo = 'https://raw.github.com/RailsApps/rails-stripe-membership-saas/master/'

    # >-------------------------------[ Migrations ]---------------------------------<

    # generate 'payola:install'
    # generate 'model Plan name stripe_id interval amount:integer --no-test-framework'
    # generate 'migration AddPlanRefToUsers plan:references'
    # generate 'migration RemoveNameFromUsers name'
    # run 'bundle exec rake db:migrate'

    # >-------------------------------[ Config ]---------------------------------<

    # copy_from_repo 'config/initializers/active_job.rb', :repo => repo
    # copy_from_repo 'db/seeds.rb', :repo => repo

    # >-------------------------------[ Assets ]--------------------------------<

    # copy_from_repo 'app/assets/stylesheets/pricing.css.scss', :repo => repo

    # # >-------------------------------[ Controllers ]--------------------------------<

    # copy_from_repo 'app/controllers/application_controller.rb', :repo => repo

    # >-------------------------------[ Jobs ]---------------------------------<

    # copy_from_repo 'app/jobs/mailing_list_signup_job.rb', :repo => repo

    # >-------------------------------[ Mailers ]--------------------------------<

    # copy_from_repo 'app/mailers/application_mailer.rb', :repo => repo

    # >-------------------------------[ Models ]--------------------------------<

    # copy_from_repo 'app/models/user.rb', :repo => repo

    # >-------------------------------[ Services ]---------------------------------<

    # copy_from_repo 'app/services/create_plan_service.rb', :repo => repo

    # >-------------------------------[ Views ]--------------------------------<

    # copy_from_repo 'app/views/content/gold.html.erb', :repo => repo

    # >-------------------------------[ Routes ]--------------------------------<

    # copy_from_repo 'config/routes.rb', :repo => repo

    # >-------------------------------[ Tests ]--------------------------------<


  # end


__END__

name: rails_datarockets_api
description: "rails-datarockets-api starter application"
author: RailsApps

requires: [git,
  setup, readme, gems, doc,
  tests,
  email,
  devise, omniauth, roles,
  frontend,
  init, analytics, deployment, extras]
category: apps
