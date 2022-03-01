module Cancannible::PreloadAdapter
  extend ActiveSupport::Concern

  included do
    # Tap Ability.new to first preload permissions via Cancannible
    alias_method :cancan_initialize, :initialize
    def initialize(user)
      Cancannible::Preloader.preload_abilities!(user, self)
      cancan_initialize(user)
    end
  end
end
