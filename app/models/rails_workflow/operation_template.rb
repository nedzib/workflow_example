module RailsWorkflow
  class OperationTemplate < ApplicationRecord
    self.table_name = "rails_workflow_operation_templates"

    belongs_to :process_template,
               class_name: "RailsWorkflow::ProcessTemplate"

    has_many :dependencies,
             class_name: "RailsWorkflow::OperationTemplateDependency",
             dependent: :destroy

    has_many :reverse_dependencies,
             class_name: "RailsWorkflow::OperationTemplateDependency",
             foreign_key: :depends_on_id,
             dependent: :destroy

    validates :title, presence: true

    scope :ordered, -> { order(:position, :id) }

    def template_instance
      @template_instance ||= begin
        if template_class.present?
          template_class.constantize.new
        else
          RailsWorkflow::BaseOperationTemplate.new
        end
      rescue NameError
        RailsWorkflow::BaseOperationTemplate.new
      end
    end

    def ready_for?(process)
      dependencies.all? { |dependency| dependency.satisfied_for?(process) }
    end

    def build_operation(process, base_context)
      context = merge_context(base_context)
      process.operations.create!(
        operation_template: self,
        state: RailsWorkflow::Operation::STATE_CREATED,
        title: title,
        assignee_id: context["assignee_id"],
        context: context
      )
    end

    private

    def merge_context(base_context)
      merged = (base_context || {}).deep_dup
      merged.merge(default_context || {})
    end
  end
end
