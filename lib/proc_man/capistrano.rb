# This file includes the required options for starting/stopping/restarting
# on deployment using Capistrano.

Capistrano::Configuration.instance(:must_exist).load do
  namespace :procman do
    task :start, :roles => fetch(:procman_roles, [:app])  do
      run procman_command(:start)
    end

    task :stop, :roles => fetch(:procman_roles, [:app]) do
      run procman_command(:stop)
    end

    task :restart, :roles => fetch(:procman_roles, [:app]) do
      run procman_command(:restart)
    end

    after 'deploy:start', "procman:start"
    after 'deploy:stop', "procman:stop"
    after 'deploy:restart', "procman:restart"

    def procman_command(command)

      procfile_path = fetch(:procfile_path, "#{current_path}/Procfile")
      procfile = procfile_path ? " --procfile #{procfile_path}" : ''

      if processes = fetch(:processes, nil)
        process_opts = "--processes #{processes}"
      else
        process_opts = ''
      end

      command = "sh -c \"cd #{current_path} && bundle exec procman #{command} --root #{current_path} --environment #{fetch(:rails_env, 'production')} #{procfile} #{process_opts} \""

      if user = fetch(:procman_user, nil)
        command = "sudo -u #{user} #{command}"
      end

      command
    end

  end
end
