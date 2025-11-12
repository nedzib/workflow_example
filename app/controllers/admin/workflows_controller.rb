module Admin
  class WorkflowsController < ApplicationController
    before_action :require_admin

    def index
      @columns = build_columns
      @processes_by_state = load_processes_by_state
      @users_by_id = load_users_by_id(@processes_by_state)
      @operation_state_labels = build_operation_state_labels
      @operation_state_order = build_operation_state_order
    end

    private

    def require_admin
      return if current_user&.admin?

      redirect_to root_path, alert: "No tienes permiso para acceder a esta sección."
    end

    def build_columns
      [
        {
          key: RailsWorkflow::Process::STATE_CREATED,
          title: "Creado",
          description: "Workflows iniciados que aún no se ponen en marcha.",
          badge_class: "bg-slate-100 text-slate-700"
        },
        {
          key: RailsWorkflow::Process::STATE_RUNNING,
          title: "En progreso",
          description: "Procesos con tareas activas o pendientes.",
          badge_class: "bg-blue-100 text-blue-700"
        },
        {
          key: RailsWorkflow::Process::STATE_COMPLETED,
          title: "Completado",
          description: "Workflows finalizados con todas las tareas cerradas.",
          badge_class: "bg-green-100 text-green-700"
        },
        {
          key: RailsWorkflow::Process::STATE_CANCELED,
          title: "Cancelado",
          description: "Procesos detenidos antes de completarse.",
          badge_class: "bg-rose-100 text-rose-700"
        }
      ]
    end

    def load_processes_by_state
      RailsWorkflow::Process
        .includes(:template, :operations)
        .order(created_at: :desc)
        .group_by(&:state)
    end

    def load_users_by_id(processes_by_state)
      user_ids = processes_by_state.values.flatten.filter_map { |process| process.context["user_id"] }
      User.where(id: user_ids).index_by(&:id)
    end

    def build_operation_state_labels
      {
        RailsWorkflow::Operation::STATE_CREATED => "Creada",
        RailsWorkflow::Operation::STATE_READY => "Lista",
        RailsWorkflow::Operation::STATE_RUNNING => "En curso",
        RailsWorkflow::Operation::STATE_DONE => "Completada",
        RailsWorkflow::Operation::STATE_SKIPPED => "Omitida",
        RailsWorkflow::Operation::STATE_CANCELED => "Cancelada"
      }
    end

    def build_operation_state_order
      [
        RailsWorkflow::Operation::STATE_RUNNING,
        RailsWorkflow::Operation::STATE_READY,
        RailsWorkflow::Operation::STATE_CREATED,
        RailsWorkflow::Operation::STATE_DONE,
        RailsWorkflow::Operation::STATE_SKIPPED,
        RailsWorkflow::Operation::STATE_CANCELED
      ]
    end
  end
end
