module WorkflowExample
  module RailsWorkflowRouteCompatibility
    RETRY_ACTION = :retry
    HTTP_METHOD = :post

    module_function

    def ensure_retry_action_support(resource)
      add_action_to_array_constant(resource, :VALID_ACTIONS)
      add_action_to_array_constant(resource, :CANONICAL_ACTIONS)
      add_action_to_hash_constant(resource, :HTTP_METHODS, HTTP_METHOD)
      add_action_to_hash_constant(resource, :RESOURCE_METHODS, HTTP_METHOD)
      add_action_to_array_constant(resource, :RESOURCE_ACTIONS)
    end

    def add_action_to_array_constant(resource, const_name)
      return unless resource.const_defined?(const_name, false)

      actions = resource.const_get(const_name)
      return unless actions.respond_to?(:include?)
      return if actions.include?(RETRY_ACTION)

      new_actions = actions.respond_to?(:dup) ? actions.dup : Array(actions)
      new_actions << RETRY_ACTION

      resource.const_set(const_name, new_actions)
    end

    def add_action_to_hash_constant(resource, const_name, value)
      return unless resource.const_defined?(const_name, false)

      mapping = resource.const_get(const_name)
      return unless mapping.respond_to?(:key?) && mapping.respond_to?(:merge)
      return if mapping.key?(RETRY_ACTION)

      resource.const_set(const_name, mapping.merge(RETRY_ACTION => value))
    end
  end
end

Rails.application.config.to_prepare do
  next unless defined?(ActionDispatch::Routing::Mapper::Resource)

  WorkflowExample::RailsWorkflowRouteCompatibility.ensure_retry_action_support(
    ActionDispatch::Routing::Mapper::Resource
  )
end
