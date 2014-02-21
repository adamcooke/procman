require 'proc_man/process'
require 'proc_man/procfile'
require 'proc_man/constraint'

module ProcMan
  
  VERSION = '1.7.0'
  
  class Error < StandardError; end
  
  class << self
    
    def load_procfile(path)
      if File.file?(path)
        ProcMan::Procfile.class_eval(File.read(path))
        puts "\e[35mProcfile loaded from #{path}\e[0m"
      else
        raise Error, "Procfile not found at #{path}"
      end
    end
    
    def processes
      @processes ||= Array.new
    end
    
    def run(method, options = {})
      load_procfile(options[:procfile] || File.expand_path('./Procfile'))
      if method.nil?
        raise Error, "Command to execute was not specified. For example, pass 'start' to start processes."
      else
        for process in self.processes
          process.options = options
          if process.defined_method?(method)
            if process.execute?
              puts "\e[33m#{method.capitalize}ing #{process.name}\e[0m"
              process.send(method)
            end
          else
            puts "\e[31mThe #{process.name} process does not implement a '#{method}' method\e[0m"
          end
        end
      end
    end
    
    # Create a new Procfile template in the current directory root
    def init
      path = File.expand_path('./Procfile')
      if File.file?(path)
        raise Error, "Procfile already exists at #{path}"
      else
        template_path = File.expand_path('../../Procfile.template', __FILE__)
        File.open(path, 'w') { |f| f.write(File.read(template_path)) }
        puts "\e[32mProcfile created at #{path}"
      end
    end
    
  end
end
