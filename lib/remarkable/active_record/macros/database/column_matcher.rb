module Remarkable # :nodoc:
  module ActiveRecord # :nodoc:
    module Matchers # :nodoc:

      def have_db_column(column, options = {})
        ColumnMatcher.new(column, options)
      end

      def have_db_columns(*columns)
        ColumnMatcher.new(*columns)
      end

      class ColumnMatcher < Remarkable::Matcher::Base

        description do
          msg = @columns.size == 1 ? "have column named :#{@columns[0]}" : 
            "have columns #{@columns.to_sentence}"
            
          msg << " with options " + @options.inspect unless @options.empty?
          msg
        end
        failure_message { "Expected #{model_name} to have a column named #{@column} (#{@missing})" }
        negative_failure_message { "Did not expect #{model_name} to have a column named #{@column}" }
                
        optional :default
        optional :precision
        optional :limit
        optional :scale
        optional :sql_type
        optional :type,     :alias   => :of_type
        optional :null,     :default => true
        optional :primary,  :default => true
        
        def initialize(*columns)
          @options = columns.extract_options!
          @columns  = columns
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@columns) do |column|
            @column = column
            has_column? && all_options_correct?
          end
        end

        protected

        def column_type
          model_class.columns.detect {|c| c.name == @column.to_s }
        end

        def has_column?
          return true if column_type
          @missing = "#{model_name} does not have column #{@column}"
          false
        end

        def all_options_correct?
          @options.each do |option, value|
            unless value.nil?
              return false unless option_correct?(option, value)
            end
          end
        end

        def option_correct?(option, expected_value)
          found_value = column_type.instance_variable_get("@#{option.to_s}").to_s

          if found_value == expected_value.to_s
            true
          else
            @missing = ":#{@column} column on table for #{model_class} does not match option :#{option}, found '#{found_value}' but expected '#{expected_value}'"
            false
          end
        end
      end
    end
  end
end
