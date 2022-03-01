# These model definitions are just used for the test scenarios

class Permission < ActiveRecord::Base
  belongs_to :permissible, polymorphic: true
  belongs_to :resource, polymorphic: true, optional: true

  validates :ability, uniqueness: { scope: [:resource_id, :resource_type, :permissible_id, :permissible_type] }
end

class Member < ActiveRecord::Base
  include Cancannible::Grantee
end

class User < ActiveRecord::Base
  has_many :roles_users, class_name: 'RolesUsers'
  has_many :roles, through: :roles_users
  belongs_to :group

  include Cancannible::Grantee
  inherit_permissions_from :roles, :group
end

class RolesUsers < ActiveRecord::Base
  belongs_to :role
  belongs_to :user
end

class Role < ActiveRecord::Base
  has_many :roles_users, class_name: 'RolesUsers'
  has_many :users, through: :roles_users

  include Cancannible::Grantee
end

class Group < ActiveRecord::Base
  has_many :users

  include Cancannible::Grantee
end

class Widget < ActiveRecord::Base
end
