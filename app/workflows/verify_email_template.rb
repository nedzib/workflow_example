class VerifyEmailTemplate < RailsWorkflow::BaseOperationTemplate
  def after_operation_started(operation)
    Rails.logger.info("[Workflow] Preparando verificación de correo para #{operation.context["user_email"]}")
    operation.context["verification_code"] = SecureRandom.hex(3).upcase
    operation.context["previous_step_note"] ||= "Perfil inicial pendiente de confirmación"
  end

  def after_operation_completed(operation)
    Rails.logger.info("[Workflow] Verificación confirmada para #{operation.context["user_email"]}")
  end
end
