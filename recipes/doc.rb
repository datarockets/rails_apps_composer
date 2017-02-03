
## doc
prefs[:doc] = multiple_choice "Documentation used?", [["none", "none"], ["Apipie", "apipie"],
  ] unless prefs.has_key? :doc

if prefer :doc, 'apipie'
  add_gem 'apipie-rails'
  run 'rails g apipie:install'
  copy_from_file 'initializers/apipie.rb', 'config/initializers/apipie.rb'
  gsub_file "config/initializers/apipie.rb", /myapp/,  "#{app_name}"

  route_text = "apipie unless Rails.env.production?\n"
  insert_into_file('config/routes.rb', route_text, after: /^.*Rails.application.routes.draw do.*\n/)

  git :init
  git :add => '-A'
  git :commit => '-qm "rails_apps_composer: initial apipie"'
end

__END__

name: dock
description: "Set up and initialize documentation."
author: Datarockets

requires: [setup, gems]
run_after: [setup, gems]
category: initialize
