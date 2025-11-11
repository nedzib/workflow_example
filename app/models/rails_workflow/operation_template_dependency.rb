module RailsWorkflow
  class OperationTemplateDependency < ApplicationRecord
    self.table_name = "rails_workflow_operation_template_dependencies"

    belongs_to :operation_template,
               class_name: "RailsWorkflow::OperationTemplate"

    belongs_to :depends_on,
               class_name: "RailsWorkflow::OperationTemplate"

    validates :required_state, presence: true

    def satisfied_for?(process)
      operation = process.operations.find_by(operation_template_id: depends_on_id)
      return false unless operation

      Array(required_state).include?(operation.state)
    end
  end
end
