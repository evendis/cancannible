Cancannible.setup do |config|
  # ABILITY CACHING
  # ===============
  # Cancannible supports optional ability caching. This can provide a significant performance
  # improvement, since abilities do not need to be recalculated on each web request.
  # No specific caching technology is enforced: you can use whatever makes sense in your application
  # environment. To enable caching, you just need to provide two methods here: `get_cached_abilities`
  # and `store_cached_abilities`.

  # Return an Ability object for +grantee+ or nil if not found
  # config.get_cached_abilities = proc{|grantee|
  #   # This is a simple example of using Redis (assumes @redis correctly connected)
  #   key = "user:#{grantee.id}:abilities"
  #   Marshal.load(@redis.get(key))
  # }

  # Command: put the +ability+ object for +grantee+ in the cache storage
  # config.store_cached_abilities = proc{|grantee,ability|
  #   # This is a simple example of using Redis (assumes @redis correctly connected)
  #   key = "user:#{grantee.id}:abilities"
  #   @redis.set(key, Marshal.dump(ability))
  # }


  # ACCESS REFINMENTS
  # =================
  # Cancannible allows general-purpose access refinements to be declared here. This will be enforced
  # in addition to any rules defined in you Ability.rb file.

  # These are primarily intended to enforce data partitioning (multi-tenancy) and general security rules such as:
  # "only show data related to customers that I have permissions to see", or
  # "make sure I can see records that I created (regardless of other restrictions)"

  # The syntax here is not as flexible as that supported in the Ability.rb file, but have the benefit of
  # potentially refining any/all permissions that are configured in the permissions tables.

  # The following examples illustrate the options that are available. These can be used individually or in combination.


  # Basic syntax example:
  #   config.refine_access customer_id: :accessible_customer_ids
  #
  # This means:
  # - for any resource permission loaded/inherited from the database
  # - where the resource has a :customer_id attribute
  # - restrict access to only those with values from my (the grantee) :accessible_customer_ids method
  #
  # In other words, say we have a Contract model that has a :customer_id attribute, and permissions are granted thus:
  #    user.can(:read,Contract)
  # Then if we define a user.accessible_customer_ids method, these values will be used to restrict user's access to Contract records
  #
  # Note: the rule is ignored if the resource does not sport the attribute mentioned, or if the grantee method is not defined.


  # Multiple conditions syntax example:
  #   config.refine_access customer_id: :accessible_customer_ids, product_id: :accessible_product_ids
  #
  # This restricts access to only records matching all conditions


  # Fixed value conditions syntax example:
  #   config.refine_access customer_id: 42, status: 'open'
  #
  # Fixed match-values may be provided instead of methods


  # Limited ability scope syntax example:
  #   config.refine_access customer_id: :accessible_customer_ids, scope: :read
  #   config.refine_access customer_id: :accessible_customer_ids, scope: [:read,:update]
  #
  # The `scope` parameter causes the rule to only be applied for the specified ability rules


  # Limited ability scope syntax example:
  #   config.refine_access customer_id: :accessible_customer_ids, except: :read
  #   config.refine_access customer_id: :accessible_customer_ids, except: [:read,:update]
  #
  # The `except` parameter causes the rule to be applied for all abilities except those specified.


  # Allow nil syntax example:
  #   config.refine_access customer_id: :accessible_customer_ids, allow_nil: true
  #
  # The `allow_nil` parameter changes the rule so that nil/NULL values are allowed through. By default, this is false.


  # Conditional syntax example:
  #   config.refine_access customer_id: :accessible_customer_ids, if: proc{|grantee,model_resource|
  #     grantee.name = 'Paul' && model_resource.is_a?(Special)
  #   }
  #
  # The `if` parameter allowws you to provide a procedure that will dynamically determine if the rule should be applied.
  # It should return true or false. The `grantee` is the actual instance that permissions are being applied to,
  # and `model_resource` is an example record (unsaved) of the kind of resource that the rule is being applied to.


  # Multi-stage refinement syntax example:
  #   config.refine_access customer_id: :accessible_customer_ids, stage: 2
  #
  # By default, access refinements are "stage 1" i.e. applied directly to the permissions being loaded.
  # By specifying stage 2, this refinement is applied on top of all stage 1 refinements (if possible / applicable)
end
