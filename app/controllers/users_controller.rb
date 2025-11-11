class UsersController < ApplicationController
  def index
    @users = User.order(created_at: :desc)
    @current_operation = current_operation_for(current_user)
    @process_map = RailsWorkflow::Process.all.each_with_object({}) do |process, hash|
      user_id = process_context(process)["user_id"]
      hash[user_id.to_i] = process if user_id.present?
    end
  end

  def show
    @user = User.find(params[:id])
    @operations = RailsWorkflow::Operation
                    .joins(:process)
                    .where("rails_workflow_processes.context ->> 'user_id' = ?", @user.id.to_s)
                    .order(:created_at)
  end

  private

  def current_operation_for(user)
    return unless user

    scope = RailsWorkflow::Operation.where(state: "running")
    if RailsWorkflow::Operation.column_names.include?("assignee_id")
      scope = scope.where(assignee_id: user.id)
      return scope.order(:created_at).first
    end

    scope.order(:created_at).detect do |operation|
      operation_context(operation)["assignee_id"].to_i == user.id
    end
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
