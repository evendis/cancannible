class CreateCancanniblePermissions < ActiveRecord::Migration
  def change
    create_table :permissions, force: true do |table|
      table.integer  :permissible_id
      table.string   :permissible_type
      table.integer  :resource_id
      table.string   :resource_type
      table.string   :ability
      table.boolean  :asserted
      table.datetime :created_at
      table.datetime :updated_at
    end
    add_index :permissions, [:permissible_id, :permissible_type], name: "index_permissions_permissible"
  end
end
