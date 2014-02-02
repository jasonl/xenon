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
        model.create_table
      end
      
      models_with_tables.each do |model|        
        table_columns = model.table_information
        required_columns = model.columns.values
        
        # What columns are already in the table?
        columns_not_in_table = required_columns.select { |c| !table_columns.detect { |tc| tc == c} }

        if columns_not_in_table.empty?
          Application.logger.info "Using existing table '#{model.table_name}' for #{model.name}"
        end
        
        # What new columns must we create?
        column_names = table_columns.map(&:name)
        new_columns = columns_not_in_table.select { |c| !column_names.include?(c.name) }
        
        new_columns.each do |column|
          Application.logger.info "Adding column '#{column.name}' to '#{model.table_name}' for #{model.name}"
          model.add_column(column)
        end

        # TODO: Alter existing columns
      end
    end
  end
end
