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
      models_with_tables = @models.select { |model| model.table_exists? }
      models_without_tables = @models - models_with_tables
      
      models_without_tables.each do |model| 
        Application.logger.info "Creating new table '#{model.table_name}' for #{model.name}"
        model.create_table!
      end
      
      models_with_tables.each do |model|
        Application.logger.info "Using existing table '#{model.table_name}' for #{model.name}"
      end
    end
  end
end
