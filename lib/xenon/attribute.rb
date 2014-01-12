module Xenon
  class Attribute
    attr_reader :column

    def initialize(column, value)
      @column = column
      @value = value
    end

    def column_name
      @column.name
    end

    def type
      @column.type
    end

    def set(val)
      @value = val
    end

    def get
      @value
    end
  end
end
