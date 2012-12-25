# ProcMan

A very very simple system for managing a list of processes which
need to be started/stopped/restarted within a Ruby application.

It works by defining a `Procfile` in the root of your application
and then using the `procman` command to either start, stop or restart
your application as a whole.

The `Procfile` is a Ruby file which you can use to define how to manipulate
your processes.

## Example Procfile

Your Procfile can contain multiple types of process and each process should define
an action which should be carried out for starting, stopping & restarting that process.

In this example, we have demonstrated two processes a unicorn web server and a worker process
powered by our Ruby backgrounding system, rbg.

```ruby
process :unicorn do

  start do
    system("umask 002 && bundle exec unicorn_rails -E #{environment} -c #{root}/config/unicorn.rb -D")
  end
  
  stop do
    system("kill `cat #{root}/tmp/pids/unicorn.#{environment}.pid`")
  end
  
  restart { stop and start }

end

process :worker do
  
  start do
    system("bundle exec rbg start -c #{root}/config/processes/worker.rb -E #{environment}")
  end
  
  stop do
    system("bundle exec rbg stop -c #{root}/config/processes/worker.rb -E #{environment}")
  end

  restart do
    system("bundle exec rbg reload -c #{root}/config/processes/worker.rb -E #{environment}")
  end
  
end
```

## Executing process commands

Once you have a Procfile, you can execute commands by sending them to the `procman`
command on your system. If you have installed procman within bundler, you can execute
the command using `bundle exec procman`.

* `procman start` - start your processes
* `procman stop` - stop your processes
* `procman restart` - restart your processes

In fact, you can define any actions you wish. You do not need to be constrained by start,
stop & restart. If you executed `procman jump`, it would call the `jump` method for each
process within your `Procfile`.

Also, You can pass options to these methods to add extra functionality.

* `-e` - allows you specify the environment which is provided as the environment variable in your methods.
* `--processes` - allows you to specify which processes (comma separated) should be executed in the action.

Some examples of how to execute these options:

```bash
$ procman start -e production
$ procman start -e production --processes worker
$ procman start --processes worker,unicorn
```

## Executing on deployment

You can use the included Capistrano recipe to automatically run your procman start/stop/restart
commands whenever you deploy. Just require the deploy recipes in your `Capfile`.

```ruby
require 'proc_man/deploy'
```
