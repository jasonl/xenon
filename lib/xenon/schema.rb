module Xenon
  class Schema
    @models = []
    @relations = []

    def self.add_relation(relation)
      @relations << relation
    end

    def self.add_model(model)
      @models << model
    end

    def self.create_tables!
      @models.each { |model| model.create_table! }
    end
  end
end
