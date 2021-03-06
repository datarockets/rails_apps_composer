# Application template recipe for the rails_apps_composer. Change the recipe here:
# https://github.com/RailsApps/rails_apps_composer/blob/master/recipes/git.rb

## Git
say_wizard "initialize git"
prefs[:git] = true unless prefs.has_key? :git

copy_from_file 'gitignore.txt', '.gitignore'
git :init
git :add => '-A'
git :commit => '-qm "rails_apps_composer: initial commit"'

__END__

name: git
description: "Initialize git for your application."
author: RailsApps

category: configuration
