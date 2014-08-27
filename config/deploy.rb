require "bundler/capistrano"

default_run_options[:pty] = true  # Must be set for the password prompt from git to work
ssh_options[:forward_agent] = true

set :application,   "mmr2strava"
set :repository,    "git@github.com:veader/#{application}.git"
set :deploy_to,     "/sites/#{application}"
set :branch,        ENV["BRANCH"] || "master"
set :user,          "web"
set :keep_releases, 5
set :use_sudo,      false

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

hostname = "mmr2strava.v8logic.com"

role :web, hostname
role :app, hostname
role :db,  hostname, :primary => true

# fun rbenv setup
set :default_environment, {
  "RBENV_ROOT" => "/usr/local/rbenv",
  "PATH" => "/usr/local/rbenv/shims:/usr/local/rbenv/bin:$PATH"
}
set :bundle_flags, "--deployment --quiet --binstubs --shebang ruby-local-exec"

after "deploy:restart", "deploy:cleanup"
after "deploy:create_symlink", "mmr2strava:link_envvars"

# --- passenger setup
namespace :deploy do
  task :start do ; end
  task :stop  do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

namespace :mmr2strava do
  task :link_envvars do
    run "ln -nfs ~/.env_#{application} #{current_path}/.env"
  end
end
