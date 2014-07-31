class Cancannible::Preloader

  def self.preload_abilities!(grantee,cancan_ability_object)
    new(grantee,cancan_ability_object).preload!
  end

  attr_accessor :grantee
  attr_accessor :cancan_ability_object

  def initialize(grantee,cancan_ability_object)
    self.grantee = grantee
    self.cancan_ability_object = cancan_ability_object
  end

  def preload!
    return unless grantee.respond_to?(:inherited_permissions)
    # load inherited permissions to CanCan Abilities
    preload_abilities_from_permissions(grantee.inherited_permissions)
    # load user-based permissions from database to CanCan Abilities
    preload_abilities_from_permissions(grantee.permissions.reload)
    # return the ability object
    cancan_ability_object
  end

  def preload_abilities_from_permissions(perms)
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
            next if refinement_if_condition.respond_to?(:call) && !refinement_if_condition.call(grantee,model_resource)

            refinement_scope = Array(refinement_attributes.delete(:scope))
            next if refinement_scope.present? &&  !refinement_scope.include?(ability)

            refinement_except = Array(refinement_attributes.delete(:except))
            next if refinement_except.present? &&  refinement_except.include?(ability)

            refinement_attribute_names = refinement_attributes.keys.map{|k| "#{k}" }
            next unless (refinement_attribute_names - model_resource.attribute_names).empty?

            restriction = {}
            refinement_attributes.each do |key,value|
              if value.is_a?(Symbol)
                if grantee.respond_to?(value)
                  restriction[key] = if allow_nil
                    Array(grantee.send(value)) + [nil]
                  else
                    grantee.send(value)
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