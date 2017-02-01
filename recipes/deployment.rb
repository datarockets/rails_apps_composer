# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/deployment.rb
base_path = 'https://raw.github.com/datarockets/rails_apps_composer/master/files/'

prefs[:deployment] = multiple_choice "Prepare for deployment?", [["no", "none"],
    ["Heroku", "heroku"],
    ["Capistrano", "capistrano3"]] unless prefs.has_key? :deployment

if prefer :deployment, 'heroku'
  say_wizard "installing gems for Heroku"
  if prefer :database, 'sqlite'
    gsub_file 'Gemfile', /.*gem 'sqlite3'\n/, ''
    add_gem 'sqlite3', group: [:development, :test]
    add_gem 'pg', '>= 0.18', group: :production
  end
end

if prefer :deployment, 'capistrano3'
  say_wizard "installing gems for Capistrano"
  add_gem 'capistrano', '~> 3.6.0', group: :development
  add_gem 'capistrano-rbenv', group: :development
  add_gem 'capistrano-rails', '~> 1.1.0', group: :development
  add_gem 'capistrano-rails-console', group: :development

  add_gem 'capistrano3-puma', group: :development if prefer :prod_webserver, 'puma'
  add_gem 'capistrano3-unicorn', group: :development if prefer :prod_webserver, 'unicorn'
  add_gem 'capistrano-thin', '~> 1.2.0', group: :development if prefer :prod_webserver, 'thin'

  stage_two do
    say_wizard "recipe stage two"
    say_wizard "installing Capistrano files"
    run 'bundle exec cap install'

    remove_file 'Capfile'
    copy_from "#{base_path}/capfiles/#{prefs[:prod_webserver]}.txt", 'Capfile'

    if prefer :prod_webserver, 'puma'
      remove_file 'config/deploy/production.rb'
      copy_from "#{base_path}/deploy/#{prefs[:prod_webserver]}/production.txt", 'config/deploy/production.rb'

      gsub_file 'config/deploy.rb', /[^lock \'[\d, \.]*\'.*\n].*/, ''
      file = File.open('files/deploy/puma/deploy.rb', 'r')
      inject_into_file 'config/deploy.rb', file.read, before: /^end/
    end
  end
end

stage_three do
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: prepare for deployment"' if prefer :git, true
end

__END__

name: deployment
description: "Prepare for deployment"
author: RailsApps

requires: [setup]
run_after: [init]
category: development
