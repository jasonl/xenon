module Xenon
  class Attribute
    attr_reader :column

    def initialize(column, value)
      @column = column
      @value = value
    end

    def set(val)
      @value = val
    end

    def get
      @value
    end
  end
end
