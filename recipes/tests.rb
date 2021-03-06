matcher_config = '
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    # Choose a test framework:
    with.test_framework :rspec

    # Choose one or more libraries:
    # with.library :active_record
    # with.library :active_model
    # with.library :action_controller
    # Or, choose the following (which implies all of the above):
    with.library :rails
  end
end
'

stage_two do
  say_wizard "recipe stage two"
  if prefer :tests, 'rspec'
    say_wizard "recipe installing RSpec"
    generate 'testing:configure rspec -f'
  end
  if prefer :continuous_testing, 'guard'
    say_wizard "recipe initializing Guard"
    run 'bundle exec guard init'
  end
  git :add => '-A' if prefer :git, true
  git :commit => '-qm "rails_apps_composer: testing framework"' if prefer :git, true
end

stage_three do
  say_wizard "recipe stage three"
  if prefer :tests, 'rspec'
    if prefer :authentication, 'devise'
      generate 'testing:configure devise -f'
      if (prefer :devise_modules, 'confirmable') || (prefer :devise_modules, 'invitable')
        inject_into_file 'spec/factories/users.rb', "    confirmed_at Time.now\n", after: "factory :user do\n"
        default_url = '  config.action_mailer.default_url_options = { :host => Rails.application.secrets.domain_name }'
        inject_into_file 'config/environments/test.rb', default_url, after: "delivery_method = :test\n"
        gsub_file 'spec/features/users/user_edit_spec.rb', /successfully./, 'successfully,'
        gsub_file 'spec/features/visitors/sign_up_spec.rb', /Welcome! You have signed up successfully./, 'A message with a confirmation'
      end
    end
    if prefer :authentication, 'omniauth'
      generate 'testing:configure omniauth -f'
    end
    if (prefer :authorization, 'roles') || (prefer :authorization, 'pundit')
      generate 'testing:configure pundit -f'
      remove_file 'spec/policies/user_policy_spec.rb'
      remove_file 'spec/support/pundit.rb' if prefer :authorization, 'roles'
      if (prefer :authentication, 'devise') &&\
        ((prefer :devise_modules, 'confirmable') || (prefer :devise_modules, 'invitable'))
        inject_into_file 'spec/factories/users.rb', "    confirmed_at Time.now\n", :after => "factory :user do\n"
      end
    end

    inject_into_file 'spec/rails_helper.rb', matcher_config, :after => "require 'rspec/rails'\n"

    remove_file 'spec/features/users/user_index_spec.rb'
    remove_file 'spec/features/users/user_show_spec.rb'
  end
end

__END__

name: tests
description: "Add testing framework."
author: RailsApps

requires: [setup, gems]
run_after: [setup, gems]
category: testing
