module Cancannible
  mattr_accessor :refinements
  mattr_accessor :get_cached_abilities
  mattr_accessor :store_cached_abilities

  # Default way to configure the gem. Yields a block that gives access to all the config variables.
  # Calling setup will reset all existing values.
  def self.setup
    reset!
    yield self
    self
  end

  def self.reset!
    self.refinements = []
    self.get_cached_abilities = nil
    self.store_cached_abilities = nil
  end
  reset!

  def self.refine_access(refinement={})
    stage = (refinement.delete(:stage) || 1) - 1
    self.refinements[stage] ||= []
    self.refinements[stage] << refinement
  end
end
