set :application, 'my_app'
set :repo_url, 'repo_url'
set :deploy_to, '/home/user/my_app'
set :ssh_options, { :forward_agent => true }

set :linked_files, %w{config/database.yml}
set :linked_dirs, %w{tmp/sockets tmp/pids log public/uploads}

set :rbenv_path, '/home/user/.rbenv/'
set :rbenv_type, :user
set :rbenv_ruby, File.read('.ruby-version').strip

set :disallow_pushing, true

set :db_remote_clean, true
set :db_local_clean, true

set :keep_releases, 5