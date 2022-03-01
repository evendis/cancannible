require 'spec_helper'

describe Cancannible do
  let(:grantee_class) { Member }
  let(:grantee) { grantee_class.create! }
  let(:cached_object) do
    abilities = Ability.new(grantee)
    abilities.can :read, :all
    abilities
  end

  describe "#abilities" do
    subject { grantee.abilities }

    context "when get_cached_abilities provided" do
      before do
        Cancannible.get_cached_abilities = proc { |grantee| cached_object }
      end

      it "returns the cached object" do
        expect(cached_object.instance_variable_defined?(:@rules_index)).to eql(true)
        expect(subject).to eql(cached_object)
      end
      context 'when incompatible cached_object' do
        let(:cached_object) { 'bogative' }
        it 'returns a new object' do
          expect(subject).to be_an(Ability)
          expect(subject).to_not eql(cached_object)
        end
      end
      context "unless reload requested" do
        subject { grantee.abilities(true) }
        it 'returns a new object' do
          expect(subject).to be_an(Ability)
          expect(subject).to_not eql(cached_object)
        end
      end
    end

    context "when store_cached_abilities provided" do
      before do
        @stored = nil
        Cancannible.store_cached_abilities = proc { |grantee, ability| @stored = { grantee_id: grantee.id, ability: ability } }
      end
      it "stores the cached object" do
        expect { subject }.to change { @stored }.from(nil)
        expect(@stored[:grantee_id]).to eql(grantee.id)
        expect(@stored[:ability]).to be_an(Ability)
      end
    end

    context "when get and store cached_abilities provided" do
      before do
        @stored = nil
        @store = 0
        Cancannible.get_cached_abilities = proc { |grantee| @stored[:ability] if @stored }
        Cancannible.store_cached_abilities = proc { |grantee, ability| @store += 1 ; @stored = { grantee_id: grantee.id, ability: ability } }
      end
      it "stores the cached object on the first call" do
        expect { subject }.to change { @stored }.from(nil)
        expect(@store).to eql(1)
        expect(@stored[:grantee_id]).to eql(grantee.id)
        expect(@stored[:ability]).to be_an(Ability)
      end
      it "returns the cached object on the second call" do
        expect { subject }.to change { @stored }.from(nil)
        expect(@store).to eql(1)
        expect { grantee.abilities }.to_not change { @store }
        expect(grantee.abilities).to be_an(Ability)
        expect(@stored[:grantee_id]).to eql(grantee.id)
      end
      it "should re-cache object on the second call if refresh requested" do
        expect { subject }.to change { @stored }.from(nil)
        expect(@store).to eql(1)
        expect { grantee.abilities(true) }.to change { @store }.from(1).to(2)
        expect(grantee.abilities).to be_an(Ability)
        expect(@stored[:grantee_id]).to eql(grantee.id)
      end
    end
  end
end
