module RailsWorkflow
  class Process < ApplicationRecord
    self.table_name = "rails_workflow_processes"

    STATE_CREATED = "created"
    STATE_RUNNING = "running"
    STATE_COMPLETED = "completed"
    STATE_CANCELED = "canceled"

    belongs_to :template,
               class_name: "RailsWorkflow::ProcessTemplate",
               foreign_key: :process_template_id

    has_many :operations,
             class_name: "RailsWorkflow::Operation",
             foreign_key: :process_id,
             dependent: :destroy

    store :context, coder: JSON

    validates :state, presence: true

    def run
      return unless state == STATE_CREATED

      update!(state: STATE_RUNNING)
      enqueue_operations!
    end

    def enqueue_operations!
      template.operation_templates.ordered.each do |operation_template|
        next if operations.exists?(operation_template_id: operation_template.id)
        next unless operation_template.ready_for?(self)

        operation = operation_template.build_operation(self, context)
        operation.activate!
      end
    end

    def refresh!
      enqueue_operations!
      check_completion!
    end

    def cancel!
      update!(state: STATE_CANCELED)
      operations.running.update_all(state: RailsWorkflow::Operation::STATE_CANCELED)
    end

    def check_completion!
      return if state == STATE_COMPLETED

      pending_states = [RailsWorkflow::Operation::STATE_CREATED,
                        RailsWorkflow::Operation::STATE_READY,
                        RailsWorkflow::Operation::STATE_RUNNING]

      if operations.where(state: pending_states).exists?
        # Still running operations
        return
      end

      update!(state: STATE_COMPLETED)
      template.template_instance.after_process_completed(self)
    end
  end
end
