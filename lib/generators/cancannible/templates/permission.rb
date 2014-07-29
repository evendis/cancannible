# The Permission class stores permissions managed by CanCan and Cancannible
class Permission < ActiveRecord::Base
  belongs_to :permissible, polymorphic: true
  belongs_to :resource, polymorphic: true

  validates_uniqueness_of :ability, scope: [:resource_id, :resource_type, :permissible_id, :permissible_type]

end