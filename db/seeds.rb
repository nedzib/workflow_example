Rails.logger.info("Reiniciando configuraciones de workflow...")

RailsWorkflow::OperationTemplateDependency.delete_all
RailsWorkflow::OperationTemplate.delete_all
RailsWorkflow::ProcessTemplate.delete_all

process_template = RailsWorkflow::ProcessTemplate.create!(
  title: "Onboarding de nuevo usuario",
  description: "Secuencia de cuatro pasos para integrar a un usuario.",
  template_class: "NewUserOnboardingProcess"
)

collect_profile = RailsWorkflow::OperationTemplate.create!(
  process_template: process_template,
  title: "Recopilar información de perfil",
  description: "Solicita información básica y completa el perfil",
  operation_type: "user",
  template_class: "CollectProfileTemplate",
  tag_list: "collect_profile",
  position: 1
)

verify_email = RailsWorkflow::OperationTemplate.create!(
  process_template: process_template,
  title: "Verificar correo electrónico",
  description: "Confirma que el usuario accede a su correo",
  operation_type: "user",
  template_class: "VerifyEmailTemplate",
  tag_list: "verify_email",
  position: 2
)

issue_credentials = RailsWorkflow::OperationTemplate.create!(
  process_template: process_template,
  title: "Emitir credenciales y accesos",
  description: "Genera usuarios en los sistemas internos",
  operation_type: "user",
  template_class: "IssueCredentialsTemplate",
  tag_list: "issue_credentials",
  position: 3
)

schedule_orientation = RailsWorkflow::OperationTemplate.create!(
  process_template: process_template,
  title: "Agendar sesión de inducción",
  description: "Coordina la inducción y cierra el onboarding",
  operation_type: "user",
  template_class: "ScheduleOrientationTemplate",
  tag_list: "schedule_orientation",
  position: 4
)

RailsWorkflow::OperationTemplateDependency.create!(
  operation_template: verify_email,
  depends_on: collect_profile,
  required_state: RailsWorkflow::Operation::STATE_DONE
)

RailsWorkflow::OperationTemplateDependency.create!(
  operation_template: issue_credentials,
  depends_on: verify_email,
  required_state: RailsWorkflow::Operation::STATE_DONE
)

RailsWorkflow::OperationTemplateDependency.create!(
  operation_template: schedule_orientation,
  depends_on: issue_credentials,
  required_state: RailsWorkflow::Operation::STATE_DONE
)

admin_email = "admin@example.com"
unless User.exists?(email: admin_email)
  User.create!(email: admin_email, password: "password123", password_confirmation: "password123")
  Rails.logger.info("Usuario administrador creado: #{admin_email}")
end

puts "Workflow sembrado con éxito"
