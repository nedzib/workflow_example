module WorkflowExample
  module RailsWorkflowRouteCompatibility
    RETRY_ACTION = :retry

    module_function

    # Rails 8 tightened the allowed actions for +resources+. The RailsWorkflow
    # gem still attempts to pass +:retry+ inside the +:only+ or +:except+
    # options, which now raises an exception. Instead of patching Rails to make
    # the action valid again we simply strip it from those options before Rails
    # performs its validation. This keeps the application bootable without
    # exposing a retry REST action that we do not use.
    def sanitize_retry_options(options)
      sanitized = nil

      %i[only except].each do |key|
        next unless options.key?(key)

        values = Array(options[key])
        next unless values.include?(RETRY_ACTION)

        sanitized ||= options.dup
        sanitized_values = values - [RETRY_ACTION]

        if sanitized_values.empty?
          sanitized.delete(key)
        else
          sanitized[key] = sanitized_values
        end
      end

      sanitized
    end

    def remove_retry_from_resource_options(_mapper, resources)
      return unless resources.last.is_a?(Hash)

      sanitized_options = sanitize_retry_options(resources.last)
      return unless sanitized_options

      resources[-1] = sanitized_options
    end
  end
end

module WorkflowExample
  module Routing
    module RetryFilter
      def resources(*resources, &block)
        WorkflowExample::RailsWorkflowRouteCompatibility.remove_retry_from_resource_options(self, resources)
        super
      end
    end
  end
end

ActionDispatch::Routing::Mapper.prepend(WorkflowExample::Routing::RetryFilter)
