class CreateRoleAssignments < ActiveRecord::Migration[7.0]
  def change
    create_table :role_assignments do |t|
      t.references :membership, null: false, foreign_key: true
      t.references :server_role, null: false, foreign_key: true

      t.timestamps
    end

    add_index :role_assignments, [:membership_id, :server_role_id], unique: true
  end
end