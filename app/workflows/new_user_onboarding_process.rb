class NewUserOnboardingProcess < RailsWorkflow::BaseProcessTemplate
  def after_process_completed(process)
    user_id = process.context["user_id"]
    Rails.logger.info("[Workflow] Proceso de onboarding completado para el usuario ##{user_id}")
  end
end
