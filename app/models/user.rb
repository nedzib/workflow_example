class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable

  after_create :start_onboarding_workflow

  private

  def start_onboarding_workflow
    template = RailsWorkflow::ProcessTemplate.find_by(title: "Onboarding de nuevo usuario")
    return unless template

    context = {
      "user_id" => id,
      "user_email" => email,
      "assignee_id" => id,
      "profile_path" => Rails.application.routes.url_helpers.user_path(id)
    }

    RailsWorkflow::Process.create!(
      template: template,
      context: context,
      state: RailsWorkflow::Process::STATE_CREATED
    ).tap(&:run)
  end
end
