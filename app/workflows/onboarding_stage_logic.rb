require "securerandom"

module OnboardingWorkflow
  module StageLogic
    module_function

    def operation_created(operation)
      attach_assignee(operation)
    end

    def operation_state_changed(operation)
      case operation.state
      when "running"
        operation_started(operation)
      when "done"
        operation_completed(operation)
      end
    end

    def process_completed(process)
      user_id = process_context(process)["user_id"]
      Rails.logger.info("[Onboarding] Proceso completado para el usuario ##{user_id}") if user_id
    end

    def operation_started(operation)
      updates = {}

      case stage(operation)
      when :collect_profile
        updates["instructions"] = "Recopila los datos básicos del perfil y confirma su exactitud."
        updates["required_fields"] = %w[nombre telefono pais]
      when :verify_email
        updates["verification_code"] = generate_code
        updates["instructions"] = "Envía el código al usuario y valida la respuesta."
      when :issue_credentials
        updates["systems"] = ["Slack", "GitHub", "Notion"]
        updates["instructions"] = "Crea cuentas en los sistemas y registra los accesos entregados."
      when :schedule_orientation
        updates["orientation_date"] = I18n.l(3.days.from_now.to_date)
        updates["instructions"] = "Coordina la sesión de inducción y comparte la agenda."
      end

      apply_context_updates(operation, updates)
    end

    def operation_completed(operation)
      updates = {}
      timestamp = Time.current

      case stage(operation)
      when :collect_profile
        updates["profile_completed_at"] = timestamp
      when :verify_email
        updates["email_verified_at"] = timestamp
      when :issue_credentials
        updates["credentials_delivered_at"] = timestamp
      when :schedule_orientation
        updates["orientation_confirmed_at"] = timestamp
      end

      apply_context_updates(operation, updates)
    end

    def stage(operation)
      tags = Array(operation.operation_template&.tag_list)
      return :collect_profile if tags.include?("collect_profile")
      return :verify_email if tags.include?("verify_email")
      return :issue_credentials if tags.include?("issue_credentials")
      return :schedule_orientation if tags.include?("schedule_orientation")

      nil
    end

    def apply_context_updates(operation, new_data)
      return if new_data.blank?

      merged = operation_context(operation).merge(new_data)
      operation.update!(context: merged)
    end

    def attach_assignee(operation)
      return unless operation.respond_to?(:has_attribute?) && operation.has_attribute?(:assignee_id)

      assignee = operation_context(operation)["assignee_id"]
      return if assignee.blank?

      operation.update!(assignee_id: assignee)
    end

    def generate_code
      SecureRandom.hex(3).upcase
    end

    def operation_context(operation)
      value = operation.context
      value.is_a?(Hash) ? value : {}
    end

    def process_context(process)
      value = process.context
      value.is_a?(Hash) ? value : {}
    end
  end
end
