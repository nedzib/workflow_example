class CollectProfileTemplate < RailsWorkflow::BaseOperationTemplate
  def after_operation_started(operation)
    Rails.logger.info("[Workflow] Iniciando recopilación de perfil para #{operation.context["user_email"]}")
    operation.context["welcome_note"] = "Enviar mensaje de bienvenida y solicitar datos personales"
  end

  def after_operation_completed(operation)
    Rails.logger.info("[Workflow] Perfil inicial completado para #{operation.context["user_email"]}")
  end
end
