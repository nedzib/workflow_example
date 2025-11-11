module RailsWorkflow
  class Operation < ApplicationRecord
    self.table_name = "rails_workflow_operations"

    STATE_CREATED = "created"
    STATE_READY = "ready"
    STATE_RUNNING = "running"
    STATE_DONE = "done"
    STATE_SKIPPED = "skipped"
    STATE_CANCELED = "canceled"

    belongs_to :process,
               class_name: "RailsWorkflow::Process",
               foreign_key: :process_id

    belongs_to :operation_template,
               class_name: "RailsWorkflow::OperationTemplate"

    store :context, coder: JSON

    validates :state, presence: true

    scope :running, -> { where(state: STATE_RUNNING) }
    scope :for_user, ->(user) { user ? where(assignee_id: user.id) : none }

    after_create :run_creation_hook

    def template_instance
      operation_template.template_instance
    end

    def activate!
      return unless state == STATE_CREATED

      update!(state: STATE_RUNNING, started_at: Time.current)
      context_will_change!
      template_instance.after_operation_started(self)
      save!
    end

    def complete
      return unless state == STATE_RUNNING

      update!(state: STATE_DONE, completed_at: Time.current)
      context_will_change!
      template_instance.after_operation_completed(self)
      save! if changed?
      process.refresh!
    end

    def skip
      return unless state.in?([STATE_RUNNING, STATE_READY])

      update!(state: STATE_SKIPPED, completed_at: Time.current)
      process.refresh!
    end

    def cancel
      return unless state.in?([STATE_RUNNING, STATE_READY, STATE_CREATED])

      update!(state: STATE_CANCELED, completed_at: Time.current)
      process.refresh!
    end

    private

    def run_creation_hook
      context_will_change!
      template_instance.after_operation_created(self)
      save! if changed?
    end
  end
end
