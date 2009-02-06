module OptionalDomain
  module ClassMethods
    def optional(*opts)
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
  end
  
  module InstanceMethods
     def with_options(options = {})
        @options ||= []
        @options.merge!(options)
        self
      end
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end