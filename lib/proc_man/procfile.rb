module ProcMan
  class Procfile
    class << self
      
      def process(name, &block)
        process = ProcMan::Process.new(name)
        process.instance_eval(&block) if block_given?
        ProcMan.processes << process
      end
      
    end
  end
end
