module Cancannible

  mattr_accessor :refinements

  # Default way to configure the gem. Yields a block that gives access to all the config variables.
  # Calling setup will reset all existing values.
  def self.setup
    reset!
    yield self
    self
  end

  def self.reset!
    self.refinements = []
  end
  reset!

  def self.refine_access(refinement={})
    self.refinements << refinement
  end

end