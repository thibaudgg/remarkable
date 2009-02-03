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

        option :default
        option :precision
        option :limit
        option :scale
        option :sql_type
        option :type,     :alias   => :of_type
        option :null,     :default => true
        option :primary,  :default => true
        
        def initialize(*columns)
          @options = columns.extract_options!
          @columns  = columns
        end

        def with_options(options = {})
          load_options(options)
          self
        end

        def matches?(subject)
          @subject = subject

          assert_matcher_for(@columns) do |column|
            @column = column
            has_column? && all_options_correct?
          end
        end

        def failure_message
          "Expected #{expectation} (#{@missing})"
        end

        def negative_failure_message
          "Did not expect #{expectation}"
        end

        def description
          description = if @columns.size == 1
            "have column named :#{@columns[0]}"
          else
            "have columns #{@columns.to_sentence}"
          end
          description << " with options " + @options.inspect unless @options.empty?
          description
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

        def expectation
          "#{model_name} to have a column named #{@column}"
        end
        
        def load_options(options)
          @options = {
            :precision => nil,
            :limit     => nil,
            :default   => nil,
            :null      => nil,
            :scale     => nil,
            :sql_type  => nil
          }.merge(extract_options(options))
        end
      end
    end
  end
end
