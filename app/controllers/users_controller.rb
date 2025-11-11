class UsersController < ApplicationController
  def index
    @users = User.order(created_at: :desc)
    @current_operation = RailsWorkflow::Operation.for_user(current_user)&.running&.first
    @process_map = RailsWorkflow::Process.all.each_with_object({}) do |process, hash|
      user_id = process.context["user_id"]
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
end
