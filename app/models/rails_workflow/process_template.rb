module RailsWorkflow
  class ProcessTemplate < ApplicationRecord
    self.table_name = "rails_workflow_process_templates"

    has_many :operation_templates,
             class_name: "RailsWorkflow::OperationTemplate",
             dependent: :destroy

    validates :title, presence: true

    def template_instance
      @template_instance ||= begin
        if template_class.present?
          template_class.constantize.new
        else
          RailsWorkflow::BaseProcessTemplate.new
        end
      rescue NameError
        RailsWorkflow::BaseProcessTemplate.new
      end
    end
  end
end
