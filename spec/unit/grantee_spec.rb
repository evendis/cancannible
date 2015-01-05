require 'spec_helper'

describe Cancannible::Grantee do
  let(:grantee_class) { Member }

  context "without permissions inheritance" do

    describe "##inheritable_permissions" do
      subject { grantee_class.inheritable_permissions }
      it { should be_empty }
    end

    subject(:grantee) { grantee_class.create! }

    describe "#abilities" do
      subject(:abilities) { grantee.abilities }
      it { should be_a(Ability) }
      it "should initialise @abilities instance var" do
        expect { abilities }.to change { grantee.instance_variable_get("@abilities") }.from(nil)
      end
    end

    context "with a symbolic resource" do
      let!(:resource) { :something }

      describe "#can?" do
        subject { grantee.can?(:read, resource) }
        context "when permission is not set" do
          it { should be_falsey }
        end
        context "when permission is set" do
          before { grantee.can(:read, resource) }
          it { should be_truthy }
        end
        context "when cannot is asserted" do
          before { grantee.cannot(:read, resource) }
          it { should be_falsey }
        end
      end

      describe "#cannot?" do
        subject { grantee.cannot?(:read, resource) }
        context "when permission is not asserted" do
          it { should be_truthy }
        end
        context "when :can already asserted" do
          before { grantee.can(:read, resource) }
          it { should be_falsey }
          context "and then reset as :cannot" do
            before { grantee.cannot(:read, resource) }
            it { should be_truthy }
          end
        end
        context "when permission is asserted" do
          before { grantee.cannot(:read, resource) }
          it { should be_truthy }
        end
      end
    end

    context "with a nil resource" do
      let!(:resource) { nil }
      describe "#can? -> nil" do
        subject { grantee.can?(:read, nil) }
        context "when permission is not set" do
          it { should be_falsey }
        end
        context "when permission is set" do
          before { grantee.can(:read, resource) }
          it { should be_truthy }
        end
      end
      describe "#can? -> ''" do
        subject { grantee.can?(:read, '') }
        context "when permission is not set" do
          it { should be_falsey }
        end
        context "when permission is set" do
          before { grantee.can(:read, resource) }
          it { should be_falsey }
        end
      end
    end


    context "with a resource class" do
      let!(:resource) { Widget }

      describe "#can?" do
        subject { grantee.can?(:read, resource) }
        context "when permission is not set" do
          it { should be_falsey }
        end
        context "when permission is set" do
          before { grantee.can(:read, resource) }
          it { should be_truthy }
        end
      end
    end

    context "with a resource instance" do
      let!(:resource) { Widget.create! }
      let!(:other_resource) { Widget.create! }

      describe "#can?" do
        subject { grantee.can?(:read, resource) }
        context "when permission is not set" do
          it { should be_falsey }
        end
        context "when permission is set" do
          before { grantee.can(:read, resource) }
          it { should be_truthy }
          context "but for other instances" do
            subject { grantee.can?(:read, other_resource) }
            it { should be_falsey }
          end
        end
      end
    end

    context "with a non-existent model" do
      describe "instance" do
        let!(:obsolete_permission) {grantee.permissions.create!(asserted: true, ability: 'manage', resource_type: 'Bogative', resource_id: 33) }
        it "should not error on load" do
          expect { grantee.abilities }.to_not raise_error
        end
      end
      describe "class" do
        let!(:obsolete_permission) {grantee.permissions.create!(asserted: true, ability: 'manage', resource_type: 'Bogative') }
        it "should not error on load" do
          grantee.abilities
          expect { grantee.abilities }.to_not raise_error
        end
      end
    end

    context "with an invalid model" do
      class SuperBogative < ActiveRecord::Base
      end
      context "instance" do
        let!(:obsolete_permission) { grantee.permissions.create!(asserted: true, ability: 'manage', resource_type: 'SuperBogative', resource_id: 33) }
        it "should not error on load" do
          expect { grantee.abilities }.to_not raise_error
        end
      end
      context "class" do
        let!(:obsolete_permission) { grantee.permissions.create!(asserted: true, ability: 'manage', resource_type: 'SuperBogative') }
        it "should not error on load" do
          expect { grantee.abilities }.to_not raise_error
        end
      end
    end

  end

end