prefs[:apps4] = 'rails-fullstack-app'
prefs[:github] = true
prefs[:analytics] = 'none'
prefs[:email] = 'smtp'
prefs[:templates] = 'slim'
prefs[:continuous_testing] = 'none'
prefs[:tests] = 'rspec'
prefs[:deployment] = 'capistrano3'
prefs[:authorization] = 'none'
prefs[:better_errors] = true
prefs[:form_builder] = 'simple_form'
prefs[:git] = true
prefs[:pry] = true
prefs[:disable_turbolinks] = true
prefs[:rubocop] = true
prefs[:rvmrc] = true
prefs[:dev_webserver] = 'puma'
prefs[:prod_webserver] = 'puma'

add_gem "cells"
add_gem "cells-rails"
add_gem 'cells-slim'

__END__

name: rails_fullstack_app
description: "rails-fullstack-app starter application"
author: RailsApps

requires: [git,
  setup, readme, gems,
  tests,
  email,
  devise, omniauth, roles,
  frontend,
  init, analytics, deployment, extras]
category: apps