module Cancannible
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

        permission = find_by_asserted_and_ability_and_resource_id_and_resource_type(
          asserted, ability, resource_id, resource_type)
        unless permission
          permission = find_or_initialize_by_asserted_and_ability_and_resource_id_and_resource_type(
            !asserted, ability, resource_id, resource_type)
          permission.asserted = asserted
          permission.save!
        end

        # if Rails.version =~ /3\.0/ # the rails 3.0 way
        #   proxy_owner.instance_variable_set :@permissions, nil # invalidate the owner's permissions collection
        #   proxy_owner.instance_variable_set :@abilities, nil # invalidate the owner's ability collection
        # else
          proxy_association.owner.instance_variable_set :@abilities, nil # invalidate the owner's ability collection
        # end
        permission
      end
    end

  end

  module ClassMethods
    def inherit_permissions_from(*relations)
      self.inheritable_permissions = relations
    end
  end

  # Returns the Ability set for the owner.
  # Set +refresh+ to true to force a reload of permissions.
  def abilities(refresh = false)
    @abilities = if refresh
      nil
    elsif get_cached_abilities.respond_to?(:call)
      get_cached_abilities.call(self)
    end
    return @abilities if @abilities

    @abilities ||= if ability_class = ('Ability'.constantize rescue nil)
      unless ability_class.included_modules.include?(Cancannible::AbilityPreloadAdapter)
        ability_class.send :include, Cancannible::AbilityPreloadAdapter
      end
      ability_class.new(self)
    end

    store_cached_abilities.call(self,@abilities) if store_cached_abilities.respond_to?(:call)
    @abilities
  end

  def preload_abilities(cancan_ability_object)
    # load inherited permissions to CanCan Abilities
    preload_abilities_from_permissions(cancan_ability_object, inherited_permissions)
    # load user-based permissions from database to CanCan Abilities
    preload_abilities_from_permissions(cancan_ability_object, self.permissions.reload)
    cancan_ability_object
  end

  def inherited_permissions
    inherited_perms = []
    self.class.inheritable_permissions.each do |relation|
      Array(self.send(relation)).each do |record|
        inherited_perms.concat(record.permissions.reload)
      end
    end
    inherited_perms
  end

  # test for a permission - persisted or dynamic (delegated to CanCan)
  def can?(ability, resource)
    abilities.can?(ability, resource)
  end

  # test for a prohibition - persisted or dynamic (delegated to CanCan)
  def cannot?(ability, resource)
    abilities.cannot?(ability, resource)
  end

  # define a persisted permission
  def can(ability, resource)
    permissions << [ability, resource]
  end

  # define a persisted prohibition
  def cannot(ability, resource)
    permissions << [ability, resource, false]
  end

  private

  def preload_abilities_from_permissions(cancan_ability_object,perms)
    perms.each do |permission|
      ability = permission.ability.to_sym
      action = permission.asserted ? :can : :cannot

      if resource_type = permission.resource_type
        begin
          resource_type = resource_type==resource_type.downcase ? resource_type.to_sym : resource_type.constantize
          model_resource = resource_type.respond_to?(:new) ? resource_type.new : resource_type
        rescue
          model_resource = nil
        end
      end

      if !resource_type || resource_type.is_a?(Symbol)
        # nil or symbolic resource types:
        # apply generic unrestricted permission to the resource_type
        cancan_ability_object.send( action,  ability, resource_type )
        next
      else
        # model-based resource types:
        # skip if we cannot get a model instance
        next unless model_resource
      end

      if permission.resource_id.nil?

        if action == :cannot
          # apply generic unrestricted permission to the class
          cancan_ability_object.send( action, ability, resource_type )
        else

          refinements = Cancannible.refinements.each_with_object([]) do |refinement,memo|
            refinement_attributes = refinement.dup

            allow_nil = !!(refinement_attributes.delete(:allow_nil))

            refinement_if_condition = refinement_attributes.delete(:if)
            next if refinement_if_condition.respond_to?(:call) && !refinement_if_condition.call(self,model_resource)

            refinement_scope = Array(refinement_attributes.delete(:scope))
            next if refinement_scope.present? &&  !refinement_scope.include?(ability)

            refinement_except = Array(refinement_attributes.delete(:except))
            next if refinement_except.present? &&  refinement_except.include?(ability)

            refinement_attribute_names = refinement_attributes.keys.map{|k| "#{k}" }
            next unless (refinement_attribute_names - model_resource.attribute_names).empty?

            restriction = {}
            refinement_attributes.each do |key,value|
              if value.is_a?(Symbol)
                if self.respond_to?(value)
                  restriction[key] = if allow_nil
                    Array(self.send(value)) + [nil]
                  else
                    self.send(value)
                  end
                end
              else
                restriction[key] = value
              end
            end
            memo.push(restriction) if restriction.present?
          end

          if refinements.empty?
            # apply generic unrestricted permission to the class
            cancan_ability_object.send( action, ability, resource_type )
          else
            refinements.each do |refinement|
              cancan_ability_object.send( action,  ability, resource_type, refinement)
            end
          end

        end

      elsif resource_type.find_by_id(permission.resource_id)
        cancan_ability_object.send( action,  ability, resource_type, id: permission.resource_id)
      end
    end
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
