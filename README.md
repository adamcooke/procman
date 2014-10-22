# ProcMan

A very very simple system for managing a list of processes which
need to be started/stopped/restarted within a Ruby application.

It works by defining a `Procfile` in the root of your application
and then using the `procman` command to either start, stop or restart
your application as a whole.

The `Procfile` is a Ruby file which you can use to define how to manipulate
your processes.

## Setting up

If you're using Bundler (you should be) and wish to use procman, just include it within
your Gemfile and run `bundle` to install it. 

```ruby
gem 'procman'
```

[![Gem Version](https://badge.fury.io/rb/procman.svg)](http://badge.fury.io/rb/procman)

Once installed, you can execute commands as shown below but you should prefix `bundle exec`
to the start of the command.

## Creating your initial Procfile

The command line tool allows you to create an example `Procfile` with a simple command. This
will create a `Procfile` in the root of the directory you are currently within. You can then
open this template and make changes as appropriate for your applications.

```bash
$ procman init
```

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

  constraint :environment => 'production', :host => /\.production\.myapp\z/
  constraint :environment => 'development', :host => /\.local\z/
  
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

### Specifying constraints

If you only want certain processes to execute under certain environments or on specific hosts,
you can use constraints to restrict these.

You can specify any number of constraints for a process as shown below. If no constraints are defined
for a specific process, it will always be included when your action is executed. If a constraint is
added, the process's action will only be invoked when at least one of the constraints is matched otherwise
it will be skipped.

Constraints are configured by adding `constraint` "rules" to your process definitions. 

```ruby
# execute always in production
constraint :environment => 'production'
# execute on hosts where the hostname ends in .local
constraint :host => /\.local\z/
# execute in prodution and where the hostname is 'app01'
constraint :environment => 'production', :host => 'app01'
# only execute if process explicity set using --processes
constraint :manual => true
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
process within your `Procfile`. There are various action names which are reserved, including:
`name`, `options`, `environment`, `host`, `root` and `constraint`.

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
require 'proc_man/capistrano'
```

If you're using Capistrano 3 require `procman/capistrano3` instead.

This requires that you are using bundler and the `procman` gem has been included in your Gemfile.

If you'd like to start/stop/restart your processes using capistrano you can issue the following command. Optionally set `-s processes=worker` to restart only your worker process.

```sh
cap procman:restart -s processes=worker
```
