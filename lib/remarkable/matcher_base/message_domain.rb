module MessageDomain
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end

  module ClassMethods
    attr_reader :messages_builder

    def messages
      yield @messages_builder
    end
  end

  module InstanceMethods
    def description
      show_message(:description)
    end

    def failure_message
      show_message(:failure)
    end

    def negative_failure_message
      show_message(:negative_failure)
    end

    protected
      def show_message(type)
        message = self.class.messages_builder.get(type)

        if message.is_a? Proc
          instance_eval &message
        elsif message
          message
        else
          "No message for this matcher! :/"
        end
      end 
  end
end