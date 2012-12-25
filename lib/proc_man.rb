require 'proc_man/process'
require 'proc_man/procfile'

module ProcMan
  
  VERSION = '1.1.1'
  
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
    
    def run(method, environment = nil)
      load_procfile(File.expand_path('./Procfile'))
      if method.nil?
        raise Error, "Command to execute was not specified. For example, pass 'start' to start processes."
      else
        for process in self.processes
          process.environment = environment
          if process.defined_method?(method)
            puts "\e[33m#{method.capitalize}ing #{process.name}\e[0m"
            process.send(method)
          else
            puts "\e[31mThe #{process.name} process does not implement a '#{method}' method\e[0m"
          end
        end
      end
    end
    
  end
end
