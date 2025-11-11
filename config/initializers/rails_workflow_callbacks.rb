Rails.application.config.to_prepare do
  next unless defined?(RailsWorkflow)

  if defined?(RailsWorkflow::Operation) && !RailsWorkflow::Operation.included_modules.include?(OnboardingWorkflow::OperationCallbacks)
    RailsWorkflow::Operation.include OnboardingWorkflow::OperationCallbacks
  end

  if defined?(RailsWorkflow::Process) && !RailsWorkflow::Process.included_modules.include?(OnboardingWorkflow::ProcessCallbacks)
    RailsWorkflow::Process.include OnboardingWorkflow::ProcessCallbacks
  end
end
