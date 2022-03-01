require 'spec_helper'

describe Cancannible do
  let(:grantee_class) { User }

  context "with mulitple sources of permissions inheritance" do
    describe "##inheritable_permissions" do
      subject { grantee_class.inheritable_permissions }
      it { should eql([:roles, :group]) }
    end

    let!(:role_a)  { Role.create! }
    let!(:role_b)  { Role.create! }
    let!(:group_a) { Group.create! }
    let!(:group_b) { Group.create! }
    subject(:grantee) do
      u = grantee_class.new(group: group_a)
      u.roles << role_a
      u.save!
      u
    end

    context "with a symbolic resource" do
      let!(:resource) { :something }

      describe "#can?" do
        subject { grantee.can?(:read, resource) }
        context "when no permission" do
          it { should be_falsey }
        end
        context "when permission assigned to grantee themselves" do
          before { grantee.can(:read, resource) }
          it { should be_truthy }
        end
        context "when permission inherited thru belongs_to association" do
          before { group_a.can(:read, resource) }
          it { should be_truthy }
        end
        context "when permission inherited thru habtm association" do
          before { role_a.can(:read, resource) }
          it { should be_truthy }
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
        context "when permission assigned to grantee themselves" do
          before { grantee.can(:read, resource) }
          it { should be_truthy }
        end
        context "when permission inherited thru belongs_to association" do
          before { group_a.can(:read, resource) }
          it { should be_truthy }
        end
        context "when permission inherited thru habtm association" do
          before { role_a.can(:read, resource) }
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
        context "when permission assigned to grantee themselves" do
          before { grantee.can(:read, resource) }
          it { should be_truthy }
          context "but for other instances" do
            subject { grantee.can?(:read, other_resource) }
            it { should be_falsey }
          end
        end
        context "when permission inherited thru belongs_to association" do
          before { group_a.can(:read, resource) }
          it { should be_truthy }
          context "but for other instances" do
            subject { grantee.can?(:read, other_resource) }
            it { should be_falsey }
          end
        end
        context "when permission inherited thru habtm association" do
          before { role_a.can(:read, resource) }
          it { should be_truthy }
          context "but for other instances" do
            subject { grantee.can?(:read, other_resource) }
            it { should be_falsey }
          end
        end
      end

      describe "#cannot?" do
        subject { grantee.cannot?(:read, resource) }
        context "when permission is not asserted for the grantee themselves" do
          it { should be_truthy }
        end
        context "when permission is not asserted but can is for the grantee themselves" do
          before { grantee.can(:read, resource) }
          it { should be_falsey }
        end
        context "when permission is not asserted but can is thru belongs_to association" do
          before { group_a.can(:read, resource) }
          it { should be_falsey }
        end
        context "when permission is not asserted but can is thru habtm association" do
          before { role_a.can(:read, resource) }
          it { should be_falsey }
        end
        context "when permission is asserted for the grantee themselves" do
          before { grantee.cannot(:read, resource) }
          it { should be_truthy }
        end
        context "when permission is asserted thru belongs_to association" do
          before { group_a.cannot(:read, resource) }
          it { should be_truthy }
        end
        context "when permission is asserted thru habtm association" do
          before { role_a.cannot(:read, resource) }
          it { should be_truthy }
        end
      end
    end
  end
end
