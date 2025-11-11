class ScheduleOrientationTemplate < RailsWorkflow::BaseOperationTemplate
  def after_operation_started(operation)
    Rails.logger.info("[Workflow] Agendando inducción para #{operation.context["user_email"]}")
    operation.context["orientation_date"] = (Date.today + 3.days).strftime("%d/%m/%Y")
    operation.context["closing_note"] = "Enviar encuesta de satisfacción después de la sesión"
  end

  def after_operation_completed(operation)
    Rails.logger.info("[Workflow] Inducción programada para #{operation.context["user_email"]}")
  end
end
