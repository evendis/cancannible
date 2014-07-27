require 'spec_helper'

describe Cancannible do
  let(:grantee_class) { Member }
  let(:grantee) { grantee_class.create! }

  describe "#get_cached_abilities" do
    let(:flag) { nil }
    before do
      Cancannible.get_cached_abilities = proc{|user| puts "get_cached_abilities" }
    end
    subject { grantee.abilities }
    it "should call" do
      subject
    end
  end
end