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
    system("umask 002 && bundle exec unicorn_rails -E production -c config/unicorn.rb -D")
  end
  
  stop do
    system("kill `cat tmp/pids/unicorn.production.pid`")
  end
  
  restart { stop and start }

end

process :worker do
  
  start do
    system("bundle exec rbg start -c config/processes/worker.rb -E production")
  end
  
  stop do
    system("bundle exec rbg stop -c config/processes/worker.rb -E production")
  end

  restart do
    system("bundle exec rbg reload -c config/processes/worker.rb -E production")
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

## Executing on deployment

You can use the included Capistrano recipe to automatically run your procman start/stop/restart
commands whenever you deploy. Just require the deploy recipes in your `Capfile`.

```ruby
require 'proc_man/deploy'
```
