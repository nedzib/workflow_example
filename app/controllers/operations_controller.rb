class OperationsController < ApplicationController
  before_action :set_operation

  def show
    template = @operation.operation_template
    tags = Array(template&.tag_list)

    if tags.include?("collect_profile")
      render "operations/collect_profile"
    elsif tags.include?("verify_email")
      render "operations/verify_email"
    elsif tags.include?("issue_credentials")
      render "operations/issue_credentials"
    elsif tags.include?("schedule_orientation")
      render "operations/schedule_orientation"
    else
      render "operations/default"
    end
  end

  def complete
    unless @operation.state.to_s == "running"
      redirect_to operation_path(@operation), alert: "La operación no se puede completar en su estado actual." and return
    end

    @operation.complete
    redirect_to next_location_after(@operation), notice: "Operación completada."
  end

  def skip
    unless %w[running ready].include?(@operation.state.to_s)
      redirect_to operation_path(@operation), alert: "La operación no se puede omitir en su estado actual." and return
    end

    @operation.skip
    redirect_to next_location_after(@operation), notice: "Operación marcada como omitida."
  end

  def cancel
    unless %w[running ready created].include?(@operation.state.to_s)
      redirect_to operation_path(@operation), alert: "La operación no se puede cancelar en su estado actual." and return
    end

    @operation.cancel
    redirect_to next_location_after(@operation), alert: "Operación cancelada."
  end

  private

  def set_operation
    @operation = RailsWorkflow::Operation.find(params[:id])

    return unless user_signed_in?

    assignee_id = @operation.try(:assignee_id)
    return if assignee_id.present? && assignee_id == current_user.id

    if assignee_id.blank?
      contextual_assignee = operation_context(@operation)["assignee_id"].to_i
      return if contextual_assignee.positive? && contextual_assignee == current_user.id
    end

    redirect_to root_path, alert: "No tienes permiso para ver esta operación."
  end

  def next_location_after(operation)
    path = operation_context(operation)["profile_path"]
    return path if path.present?

    users_path
  end

  def operation_context(operation)
    value = operation.context
    value.is_a?(Hash) ? value : {}
  end
end
