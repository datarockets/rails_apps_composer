
stage_two do
  say_wizard "recipe stage two"
  if prefer :authentication, 'devise'
    # prevent logging of password_confirmation
    gsub_file 'config/initializers/filter_parameter_logging.rb', /:password/, ':password, :password_confirmation'
    generate 'devise:install'
    generate 'devise_invitable:install' if prefer :devise_modules, 'invitable'
    generate 'devise user'
    generate 'migration AddNameToUsers name:string'

    if (prefer :devise_modules, 'confirmable') || (prefer :devise_modules, 'invitable')
      gsub_file 'app/models/user.rb', /:registerable,/, ":registerable, :confirmable,"
      generate 'migration AddConfirmableToUsers confirmation_token:string confirmed_at:datetime confirmation_sent_at:datetime unconfirmed_email:string'
    end
    run 'bundle exec rake db:migrate'

    git :add => '-A' if prefer :git, true
    git :commit => '-qm "rails_apps_composer: devise"' if prefer :git, true
  end
end

__END__

name: devise
description: "Add Devise for authentication"
author: RailsApps

requires: [setup, gems]
run_after: [setup, gems]
category: mvc
