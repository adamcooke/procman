module ProcMan
  class Process
    
    attr_writer :options
    
    def initialize(name)
      @name = name
    end
    
    def name
      @name
    end
    
    def options
      @options ||= {}
    end
    
    def environment
      self.options[:environment] || self.options[:e] || self.options[:env] || 'development'
    end
    
    def root
      @root ||= File.expand_path('./')
    end
    
    def execute?
      self.options[:processes].nil? || self.options[:processes].split(',').include?(self.name.to_s)
    end
    
    def method_missing(method, &block)
      if block_given?
        instance_variable_set("@#{method}", block)
      elsif block = instance_variable_get("@#{method}")
        block.call
      else
        return false
      end
    end
    
    def defined_method?(name)
      instance_variable_get("@#{name}").is_a?(Proc)
    end
        
  end
end
