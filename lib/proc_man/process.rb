module ProcMan
  class Process

    attr_writer :options

    # Initializes the new process by receiving it's name
    def initialize(name)
      @name = name
      @constraints = []
    end

    # Returns the name of the process
    def name
      @name
    end

    # Returns a hash of options which the user has specified
    def options
      @options ||= {}
    end

    # Returns the current environment
    def environment
      self.options[:environment] || self.options[:e] || self.options[:env] || 'development'
    end

    # Returns the current root directory path
    def root
      self.options[:root] || self.options[:r] || File.expand_path('./')
    end

    ## Returns the current hostname of the machine executing this action
    def host
      @host ||= `hostname -f`.strip
    end

    ## Returns whether this process is explicitly listed
    def manual
      return @manual unless @manual.nil?
      @manual = self.options[:processes] && self.options[:processes].split(',').include?(self.name.to_s)
    end

    ## Sets a constraint for this process
    def constraint(hash = {})
      @constraints << Constraint.new(self, hash)
    end

    ## Return all processes which should execute
    def processes_to_execute
      (self.options[:processes] || self.options[:p])
    end

    # Specifies whether or not actions for this process should be executed
    # in the current context.
    def execute?
      (@constraints.empty? || @constraints.any?(&:matches?)) &&
      (self.processes_to_execute.nil? || self.processes_to_execute.split(',').include?(self.name.to_s))
    end

    # Specifies whether or not the provided method has been defined in the Procfile
    # for this process.
    def defined_method?(name)
      instance_variable_get("@#{name}").is_a?(Proc)
    end

    # Stores and calls different process actions for this process. If there is no
    # block provided and we don't have a method it will return false otherwise it
    # will store or call the action as appropriate.
    def method_missing(method, &block)
      if block_given?
        instance_variable_set("@#{method}", block)
      elsif block = instance_variable_get("@#{method}")
        block.call
      else
        return false
      end
    end

    def run(command)
      puts "      \e[36m#{command}\e[0m"
      system(command)
    end

    # A shortcut method for defining a set of RBG processes
    def rbg(options = {})
      options[:config_file] ||= "Rbgfile"
      start     { run("rbg start -c #{root}/#{options[:config_file]} -E #{environment}") }
      stop      { run("rbg stop -c #{root}/#{options[:config_file]} -E #{environment}") }
      restart   { run("rbg restart -c #{root}/#{options[:config_file]} -E #{environment}") }
    end

    # A shortcut method for defining a unicorn-like process
    def unicorn(options = {})
      options[:name]            ||= 'unicorn'
      options[:config_file]     ||= "config/#{options[:name]}.rb"
      options[:pid_path]        ||= "log/#{options[:name]}.pid"
      options[:rackup_file]     ||= "config.ru"

      pid_path    = options[:pid_path][0,1] == "/" ? options[:pid_path] : "#{root}/#{options[:pid_path]}"
      config_file = options[:config_file][0,1] == "/" ? options[:config_file] : "#{root}/#{options[:config_file]}"
      rackup_file = options[:rackup_file][0,1] == "/" ? options[:rackup_file] : "#{root}/#{options[:rackup_file]}"

      start     { run("bundle exec #{options[:name]} -D -E #{environment} -c #{config_file} #{rackup_file}") }
      stop      { run("kill `cat #{pid_path}`") if File.exist?(pid_path) }
      restart   { run("kill -USR2 `cat #{pid_path}`") if File.exist?(pid_path) }
    end

  end
end
