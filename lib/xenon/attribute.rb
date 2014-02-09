module Xenon
  class Attribute
    attr_reader :column, :dirty

    def initialize(column, value)
      @column = column
      @value = value
      @dirty = false
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
      @dirty = true
    end

    def get
      @value
    end

    def reset
      @dirty = false
    end
  end
end
