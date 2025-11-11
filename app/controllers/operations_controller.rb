class OperationsController < ApplicationController
  before_action :set_operation

  def show
    if @operation.operation_template.tag_list.include?("collect_profile")
      render "operations/collect_profile"
    elsif @operation.operation_template.tag_list.include?("verify_email")
      render "operations/verify_email"
    elsif @operation.operation_template.tag_list.include?("issue_credentials")
      render "operations/issue_credentials"
    elsif @operation.operation_template.tag_list.include?("schedule_orientation")
      render "operations/schedule_orientation"
    else
      render "operations/default"
    end
  end

  def complete
    unless @operation.state == RailsWorkflow::Operation::STATE_RUNNING
      redirect_to operation_path(@operation), alert: "La operación no se puede completar en su estado actual." and return
    end
    @operation.complete
    redirect_to next_location_after(@operation), notice: "Operación completada."
  end

  def skip
    unless @operation.state.in?([RailsWorkflow::Operation::STATE_RUNNING, RailsWorkflow::Operation::STATE_READY])
      redirect_to operation_path(@operation), alert: "La operación no se puede omitir en su estado actual." and return
    end
    @operation.skip
    redirect_to next_location_after(@operation), notice: "Operación marcada como omitida."
  end

  def cancel
    unless @operation.state.in?([RailsWorkflow::Operation::STATE_RUNNING, RailsWorkflow::Operation::STATE_READY, RailsWorkflow::Operation::STATE_CREATED])
      redirect_to operation_path(@operation), alert: "La operación no se puede cancelar en su estado actual." and return
    end
    @operation.cancel
    redirect_to next_location_after(@operation), alert: "Operación cancelada."
  end

  private

  def set_operation
    @operation = RailsWorkflow::Operation.find(params[:id])
    unless @operation.assignee_id == current_user.id
      redirect_to root_path, alert: "No tienes permiso para ver esta operación." and return
    end
  end

  def next_location_after(operation)
    path = operation.context["profile_path"]
    return path if path.present?

    users_path
  end
end
