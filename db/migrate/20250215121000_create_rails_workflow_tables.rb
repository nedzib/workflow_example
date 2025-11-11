class CreateRailsWorkflowTables < ActiveRecord::Migration[7.2]
  def change
    create_table :rails_workflow_process_templates do |t|
      t.string :title, null: false
      t.text :description
      t.string :template_class
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end

    create_table :rails_workflow_operation_templates do |t|
      t.references :process_template, null: false, foreign_key: { to_table: :rails_workflow_process_templates }
      t.string :title, null: false
      t.text :description
      t.string :operation_type, null: false, default: "user"
      t.string :template_class
      t.string :tag_list, null: false, default: ""
      t.integer :position, null: false, default: 0
      t.jsonb :default_context, null: false, default: {}
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end

    create_table :rails_workflow_operation_template_dependencies do |t|
      t.references :operation_template, null: false, foreign_key: { to_table: :rails_workflow_operation_templates }
      t.references :depends_on, null: false, foreign_key: { to_table: :rails_workflow_operation_templates }
      t.string :required_state, null: false, default: "done"
      t.timestamps
    end

    create_table :rails_workflow_processes do |t|
      t.references :process_template, null: false, foreign_key: { to_table: :rails_workflow_process_templates }
      t.string :state, null: false, default: "created"
      t.jsonb :context, null: false, default: {}
      t.timestamps
    end

    create_table :rails_workflow_operations do |t|
      t.references :process, null: false, foreign_key: { to_table: :rails_workflow_processes }
      t.references :operation_template, null: false, foreign_key: { to_table: :rails_workflow_operation_templates }
      t.string :state, null: false, default: "created"
      t.string :title, null: false, default: ""
      t.integer :assignee_id
      t.jsonb :context, null: false, default: {}
      t.datetime :started_at
      t.datetime :completed_at
      t.timestamps
    end

    add_index :rails_workflow_operations, :assignee_id
  end
end
