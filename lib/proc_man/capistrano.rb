# This file includes the required options for starting/stopping/restarting
# on deployment using Capistrano.

Capistrano::Configuration.instance(:must_exist).load do
  namespace :procman do
    task :start, :roles => :app  do
      run procman_command(:start)
    end

    task :stop, :roles => :app do
      run procman_command(:stop)
    end

    task :restart, :roles => :app do
      run procman_command(:restart)
    end

    after 'deploy:start', "procman:start"
    after 'deploy:stop', "procman:stop"
    after 'deploy:restart', "procman:restart"
    
    def procman_command(command)
      command = "sh -c \"cd #{current_path} && bundle exec procman #{command} --environment #{fetch(:rails_env, 'production')}\""
      if user = fetch(:procman_user, nil)
        command = "sudo -u #{user} #{command}" 
      end
      
      procfile_path = fetch(:procfile_path, "./Procfile")
      if procfile_path
        command << " --procfile #{procfile_path}"
      end
      command
    end
    
  end
end
