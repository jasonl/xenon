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

    def set(val, requires_type_casting = false)
      if requires_type_casting
        @value = @column.cast_to_type(val)
      else
        @value = val
      end
    end

    def get
      @value
    end
  end
end
