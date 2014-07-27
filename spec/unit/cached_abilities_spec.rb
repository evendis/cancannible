require 'spec_helper'

describe Cancannible do
  let(:grantee_class) { Member }
  let(:grantee) { grantee_class.create! }

  describe "#abilities" do
    subject { grantee.abilities }

    context "when get_cached_abilities provided" do
      before do
        Cancannible.get_cached_abilities = proc{|grantee| "get_cached_abilities for #{grantee.id}" }
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
        Cancannible.store_cached_abilities = proc{ |grantee,ability| @stored = { grantee_id: grantee.id, ability: ability } }
      end
      it "should store the cached object" do
        expect { subject }.to change { @stored }.from(nil)
        expect(@stored[:grantee_id]).to eql(grantee.id)
        expect(@stored[:ability]).to be_an(Ability)
      end
    end

    context "when get and store cached_abilities provided" do
      before do
        @stored = nil
        @store = 0
        Cancannible.get_cached_abilities = proc{|grantee| @stored }
        Cancannible.store_cached_abilities = proc{ |grantee,ability| @store += 1 ; @stored = { grantee_id: grantee.id, ability: ability } }
      end
      it "should store the cached object on the first call" do
        expect { subject }.to change { @stored }.from(nil)
        expect(@store).to eql(1)
        expect(@stored[:grantee_id]).to eql(grantee.id)
        expect(@stored[:ability]).to be_an(Ability)
      end
      it "should return the cached object on the second call" do
        expect { subject }.to change { @stored }.from(nil)
        expect(@store).to eql(1)
        expect { grantee.abilities }.to_not change { @store }
        expect(grantee.abilities[:grantee_id]).to eql(grantee.id)
        expect(grantee.abilities[:ability]).to be_an(Ability)
      end
      it "should re-cache object on the second call if refresh requested" do
        expect { subject }.to change { @stored }.from(nil)
        expect(@store).to eql(1)
        expect { grantee.abilities(true) }.to change { @store }.from(1).to(2)
        expect(grantee.abilities[:grantee_id]).to eql(grantee.id)
        expect(grantee.abilities[:ability]).to be_an(Ability)
      end
    end


  end

end