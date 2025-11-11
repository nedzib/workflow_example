module RailsWorkflow
  class BaseOperationTemplate
    def after_operation_created(_operation); end

    def after_operation_started(_operation); end

    def after_operation_completed(_operation); end
  end
end
