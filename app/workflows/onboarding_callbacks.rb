module OnboardingWorkflow
  module OperationCallbacks
    extend ActiveSupport::Concern

    included do
      after_create_commit -> { OnboardingWorkflow::StageLogic.operation_created(self) }
      after_update_commit :run_onboarding_state_callbacks
    end

    private

    def run_onboarding_state_callbacks
      return unless saved_change_to_state?

      OnboardingWorkflow::StageLogic.operation_state_changed(self)
    end
  end

  module ProcessCallbacks
    extend ActiveSupport::Concern

    included do
      after_update_commit :run_onboarding_completion_callback
    end

    private

    def run_onboarding_completion_callback
      return unless saved_change_to_state?
      return unless state.to_s == "completed"

      OnboardingWorkflow::StageLogic.process_completed(self)
    end
  end
end
