module Cancannible::Grantee
  extend ActiveSupport::Concern

  included do
    class_attribute :inheritable_permissions
    self.inheritable_permissions = [] # default

    has_many :permissions, as: :permissible, dependent: :destroy do
      # generally use instance.can method, not permissions<< directly
      def <<(arg)
        ability, resource = arg
        resource = nil if resource.blank?
        asserted = arg[2].nil? ? true : arg[2]

        case resource
        when Class, Symbol
          resource_type = resource.to_s
          resource_id = nil
        when nil
          resource_type = resource_id = nil
        else
          resource_type = resource.class.to_s
          resource_id = resource.try(:id)
        end

        # This looks ugly, but it avoid version-specific issues with find_by*/find_or_initialize_by* methods
        permission = where(asserted: asserted, ability: ability, resource_id: resource_id, resource_type: resource_type).first
        permission ||= where(asserted: !asserted, ability: ability, resource_id: resource_id, resource_type: resource_type).first
        permission ||= new(asserted: asserted, ability: ability, resource_id: resource_id, resource_type: resource_type)
        permission.asserted = asserted
        permission.save!

        proxy_association.owner.instance_variable_set :@abilities, nil # invalidate the owner's ability collection

        permission
      end
    end

  end

  module ClassMethods

    # Command: configures the set of associations (array of symbols) from which permissions should be inherited
    def inherit_permissions_from(*relations)
      self.inheritable_permissions = relations
    end

  end

  # Returns the Ability set for the owner.
  # Set +refresh+ to true to force a reload of permissions.
  def abilities(refresh = false)
    @abilities = if refresh
      nil
    elsif Cancannible.get_cached_abilities.respond_to?(:call)
      Cancannible.get_cached_abilities.call(self)
    end
    return @abilities if @abilities

    @abilities ||= if ability_class = ('Ability'.constantize rescue nil)
      unless ability_class.included_modules.include?(Cancannible::PreloadAdapter)
        ability_class.send :include, Cancannible::PreloadAdapter
      end
      ability_class.new(self)
    end

    Cancannible.store_cached_abilities.call(self,@abilities) if Cancannible.store_cached_abilities.respond_to?(:call)
    @abilities
  end

  # Returns the collection of inherited permission records
  def inherited_permissions
    inherited_perms = []
    self.class.inheritable_permissions.each do |relation|
      Array(self.send(relation)).each do |record|
        inherited_perms.concat(record.permissions.reload)
      end
    end
    inherited_perms
  end

  # Returns true it the +ability+ is permitted on +resource+ - persisted or dynamic (delegated to CanCan)
  def can?(ability, resource)
    abilities.can?(ability, resource)
  end

  # Returns true it the +ability+ is prohibited on +resource+ - persisted or dynamic (delegated to CanCan)
  def cannot?(ability, resource)
    abilities.cannot?(ability, resource)
  end

  # Command: grant the permission to do +ability+ on +resource+
  def can(ability, resource)
    permissions << [ability, resource]
  end

  # Command: prohibit the permission to do +ability+ on +resource+
  def cannot(ability, resource)
    permissions << [ability, resource, false]
  end

end


module Cancannible
  # This module is automatically included into all controllers.
  # It overrides some CanCan ControllerAdditions
  module ControllerAdditions
    def current_ability
      current_user.try(:abilities)
    end
  end
end

if defined? ActionController::Base
  ActionController::Base.class_eval do
    include Cancannible::ControllerAdditions
  end
end
