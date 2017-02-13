# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/frontend.rb

if prefer :npm, 'npm'
  run 'npm init'
  insert_code = "config.assets.paths << Rails.root.join('node_modules')"
  inject_into_file 'config/application.rb', insert_code, after: /class Application < Rails::Application\n/
  run 'npm install'
  run 'npm install jquery'
  run 'npm install jquery_ujs'
  if prefs[:frontend] == 'bootstrap4'
    run 'npm install bootstrap@4.0.0-alpha.6'
  elsif prefs[:frontend] == 'foundation6'
    run 'npm install foundation-sites@6.3.0'
  end
else
  if prefs[:frontend] == 'bootstrap4'
    add_gem 'bootstrap', '~> 4.0.0.alpha3.1'
  elsif prefs[:frontend] == 'foundation6'
    add_gem 'foundation-rails', '~> 6.3'
  end
end

### GIT ###
git :add => '-A' if prefer :git, true
git :commit => '-qm "rails_apps_composer: front-end framework"' if prefer :git, true

__END__

name: frontend
description: "Install a front-end framework for HTML5 and CSS."
author: RailsApps

requires: [setup, gems]
run_after: [setup, gems, devise, omniauth, roles]
category: frontend
