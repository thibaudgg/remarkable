require "remarkable/matcher_base/matcher_specific_language"

module Remarkable # :nodoc:
  module Matcher # :nodoc:
    class Base
      include MessageDomain
      include OptionalDomain
      
      ####################
      # CLASS METHODS
      ####################

      # Initialize our message_build class level instance variable in every
      # class that inherit from us.
      #
      def self.inherited(base)
        base.class_eval do
          @messages_builder = MessageBuilder.new
        end
      end

      def self.extract_options(options)
        options.last.is_a?(::Hash) ? options.pop : {}
      end

      def self.default(name)
        
      end

      ####################
      # INSTANCE METHODS
      ####################
      def initialize(*options)
        @options = options.extract_options!
        @default = options
      end
      

      def initialize(*options)
        @options = options.extract_options!
        @default = options
      end


      def negative
        @negative = true
        self
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
