module ProcMan
  class Constraint

    def initialize(process, conditions)
      @process      = process
      @conditions   = conditions
    end

    def matches?
      matches = 0
      for key, value in @conditions
        matches += 1 if compare(value, @process.send(key).to_s.downcase)
      end
      @conditions.size > 0 && matches == @conditions.size
    end

    private

    def compare(condition, value)
      value = value.to_s.downcase
      case condition
      when String
        condition.to_s.downcase == value
      when Regexp
        !!condition.match(value)
      when Array
        condition.any? { |c| compare(c, value) }
      when TrueClass
        value == "true"
      else
        false
      end
    end

  end
end
