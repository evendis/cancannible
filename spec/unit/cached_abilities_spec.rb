require 'spec_helper'

describe Cancannible do
  let(:grantee_class) { Member }
  let(:grantee) { grantee_class.create! }

  describe "#abilities" do
    subject { grantee.abilities }

    context "when get_cached_abilities provided" do
      before do
        Cancannible.get_cached_abilities = proc{|user| "get_cached_abilities for #{user.id}" }
      end
      it "should returned the cached object" do
        should eql("get_cached_abilities for #{grantee.id}")
      end
      context "unless reload requested" do
        subject { grantee.abilities(true) }
        it { should be_an(Ability) }
      end
    end

    context "when store_cached_abilities provided" do
      before do
        @stored = nil
        Cancannible.store_cached_abilities = proc{ |user,ability| @stored = { user_id: user.id, ability: ability } }
      end
      it "should store the cached object" do
        expect { subject }.to change { @stored }.from(nil)
        expect(@stored[:user_id]).to eql(grantee.id)
        expect(@stored[:ability]).to be_an(Ability)
      end
    end

  end

end