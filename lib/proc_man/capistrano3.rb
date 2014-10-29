SSHKit.config.command_map[:procman] = '/usr/bin/env bundle exec procman'

namespace :procman do
  desc 'Start procman processes'
  task :start do
    on roles(fetch(:procman_roles)) do
      within release_path do
        execute :procman, procman_command(:start)
      end
    end
  end

  desc 'Stop procman processes'
  task :stop do
    on roles(fetch(:procman_roles)) do
      within release_path do
        execute :procman, procman_command(:stop)
      end
    end
  end

  desc 'Restart procman processes'
  task :restart do
    on roles(fetch(:procman_roles)) do
      within release_path do
        execute :procman, procman_command(:restart)
      end
    end
  end

  after 'deploy:restart', "procman:restart"

  def procman_command(command)

    procfile_path = fetch(:procfile_path, "#{current_path}/Procfile")
    procfile = procfile_path ? " --procfile #{procfile_path}" : ''

    if processes = fetch(:processes, nil)
      process_opts = "--processes #{processes}"
    else
      process_opts = ''
    end

    #command = "sh -c \"cd #{current_path} && bundle exec procman #{command} --root #{current_path} --environment #{fetch(:rails_env, 'production')} #{procfile} #{process_opts} \""
    command = "#{command} --root #{current_path} --environment #{fetch(:rails_env, 'production')} #{procfile} #{process_opts}"

    if user = fetch(:procman_user, nil)
      command = "sudo -u #{user} #{command}"
    end

    command
  end

end

namespace :load do
  task :defaults do
    set :procman_roles, fetch(:procman_roles, [:app])
  end
end
