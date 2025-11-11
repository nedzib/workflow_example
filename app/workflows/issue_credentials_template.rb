class IssueCredentialsTemplate < RailsWorkflow::BaseOperationTemplate
  def after_operation_started(operation)
    Rails.logger.info("[Workflow] Generando credenciales para #{operation.context["user_email"]}")
    operation.context["systems"] = ["Slack", "GitHub", "Notion"]
    operation.context["credential_note"] = "Recuerda configurar 2FA en todos los accesos"
  end

  def after_operation_completed(operation)
    Rails.logger.info("[Workflow] Credenciales listas para #{operation.context["user_email"]}")
  end
end
