module Remarkable # :nodoc:
  module Matcher # :nodoc:
    class Base

      ####################
      # CLASS METHODS
      ####################

      def self.extract_options(options)
        options.last.is_a?(::Hash) ? options.pop : {}
      end

      def self.optional(*opts)
        name = opts.first.to_s
        options = extract_options(opts)
        class_eval <<-END
        def #{name}(value#{ options[:default] ? "=#{options[:default]}" : "" })
          @options ||= {}
          @options[:#{name}] = value
          self
        end
        END
        class_eval "alias_method(:#{options[:alias]}, :#{name})" if options[:alias]
      end

      def self.description(&block)
        create_message "description", &block
      end

      def self.failure_message(&block)
        create_message "failure_message", &block
      end

      def self.negative_failure_message(&block)
        create_message "negative_failure_message", &block
      end

      def self.create_message(name, &block)
        define_method(name) do
          instance_eval(&block)
        end
      end

      ####################
      # INSTANCE METHODS
      ####################

      def with_options(options = {})
        @options ||= []
        @options.merge!(options)
        self
      end

      def description
        messages.instance_variable_get("@description")
      end

      def failure_message
        messages.instance_variable_get("@failure_message")
      end

      def negative_failure_message
        messages.instance_variable_get("@negative_failure_message")
      end



      def negative
        @negative = true
        self
      end

      def failure_message
        debugger
        @failure_message ||= "Expected #{expectation} (#{@missing})"
      end

      def negative_failure_message
        "Did not expect #{expectation}"
      end

      def controller(controller)
        @controller = controller
        self
      end

      def response(response)
        @response = response
        self
      end

      def session(session)
        @session = session
        self
      end

      def flash(flash)
        @flash = flash
        self        
      end

      def spec(spec)
        @spec = spec
        self
      end

      protected
        def messages
          self.class.instance_variable_get("@msg")
        end

      private

      def model_class
        @subject.is_a?(Class) ? @subject : @subject.class
      end

      def model_name
        model_class.name
      end

      def positive?
        @negative ? false : true
      end

      def negative?
        @negative ? true : false
      end

      def assert_matcher(&block)
        if positive?
          return false unless yield
        else
          return true if yield
        end
        positive?
      end

      def assert_matcher_for(collection, &block)
        collection.each do |item|
          if positive?
            return false unless yield(item)
          else
            return true if yield(item)
          end
        end
        positive?
      end

      def extract_options(*options)
        options.last.is_a?(::Hash) ? options.pop : {}
      end

      def remove_parenthesis(text)
        /#{text.gsub(/\s?\(.*\)$/, '')}/
      end
    end
  end
end
