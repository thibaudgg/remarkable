# Class for messages processing of the matchers.
# 
class MessagesBuilder
  def initialize
    @description      = nil
    @failure          = nil
    @negative_failure = nil
  end

  def description(arg = nil, &block)
    @description = arg || block
  end

  def failure(arg = nil, &block)
    @failure = arg || block
  end

  def negative_failure(arg = nil, &block)
    @negative_failure = arg || block
  end

  # Method to get the messages's text or Proc.
  # 
  def get(message)
    instance_variable_get("@#{message}")
  end
end
