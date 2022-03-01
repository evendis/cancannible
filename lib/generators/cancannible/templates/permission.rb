# The Permission class stores permissions managed by CanCan and Cancannible
class Permission < ActiveRecord::Base
  belongs_to :permissible, polymorphic: true
  belongs_to :resource, polymorphic: true, optional: true

  validates :ability, uniqueness: { scope: [:resource_id, :resource_type, :permissible_id, :permissible_type] }

  # Note: for Rails 3 you may need to declare attr_accessible as follows, depending on your whitelist_attributes setting.
  # A future version of cancannible should make this unnecessary.
  #
  # attr_accessible :asserted, :ability, :resource_id, :resource_type
end
