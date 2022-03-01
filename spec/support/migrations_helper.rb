module MigrationsHelper
  def run_migrations
    ActiveRecord::Base.establish_connection({
        adapter:   'sqlite3',
        database:  ':memory:'
    })

    ActiveRecord::Migration.suppress_messages do
      ActiveRecord::Schema.define(:version => 0) do
        create_table "members", :force => true do |t|
          t.string   "name"
          t.string   "email"
        end

        create_table "users", :force => true do |t|
          t.string   "username"
          t.string   "email"
          t.integer  "group_id"
        end

        create_table "permissions", :force => true do |t|
          t.boolean  "asserted"
          t.integer  "permissible_id"
          t.string   "permissible_type"
          t.integer  "resource_id"
          t.string   "resource_type"
          t.string   "ability"
          t.datetime "created_at"
          t.datetime "updated_at"
        end

        create_table "roles", :force => true do |t|
          t.string   "name"
        end

        create_table "roles_users", :force => true do |t|
          t.string   "name"
          t.integer  "role_id"
          t.integer  "user_id"
        end

        create_table "groups", :force => true do |t|
          t.string   "name"
        end

        create_table "widgets", :force => true do |t|
          t.string   "name"
          t.integer  "category_id"
        end
      end
    end
  end
end

RSpec.configure do |conf|
  conf.include MigrationsHelper
end
