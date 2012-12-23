module ProcMan
  class Process
    
    def initialize(name)
      @name = name
    end
    
    def name
      @name
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
