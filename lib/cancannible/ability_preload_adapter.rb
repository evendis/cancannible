module Cancannible::AbilityPreloadAdapter
  extend ActiveSupport::Concern

  included do

    # Tap Ability.new to first preload permissions via Cancannible
    alias_method :cancan_initialize, :initialize
    def initialize(user)
      user.preload_abilities(self) if user.respond_to? :preload_abilities
      cancan_initialize(user)
    end

  end

end