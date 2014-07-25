require 'spec_helper'


describe Cancannible do
  let(:grantee_class) { User }
  let(:ability) { :blow }
  let(:username) { 'username' }

  subject(:grantee) { grantee_class.create!(username: username) }

  describe "#can?" do

    context "with custom attribute association restriction" do
      let(:resource_class) { Widget }
      before do
        Cancannible.setup do |config|
          config.refine_access category_id: :category_ids
        end
        allow(grantee).to receive(:category_ids).and_return([1,3])
        grantee.can(ability,resource_class)
      end
      let!(:resource) { resource_class.create(category_id: category_id) }
      subject { grantee.can?(ability,resource) }
      context "with resource within scope" do
        let(:category_id) { 3 }
        it { should be_truthy }
      end
      context "with resource not in scope" do
        let(:category_id) { 2 }
        it { should be_falsey }
      end
    end

    context "with custom attribute association restriction scoped by ability" do
      let(:resource_class) { Widget }
      let(:other_ability) { :suck }
      before do
        Cancannible.setup do |config|
          config.refine_access category_id: :category_ids, scope: ability
        end
        allow(grantee).to receive(:category_ids).and_return([1,3])
        grantee.can(ability,resource_class)
        grantee.can(other_ability,resource_class)
      end
      let!(:resource) { resource_class.create(category_id: category_id) }
      context "when scoped ability" do
        subject { grantee.can?(ability,resource) }
        context "with resource within scope" do
          let(:category_id) { 3 }
          it { should be_truthy }
        end
        context "with resource not in scope" do
          let(:category_id) { 2 }
          it { should be_falsey }
        end
      end
      context "when other ability" do
        subject { grantee.can?(other_ability,resource) }
        context "with resource within scoped ability" do
          let(:category_id) { 3 }
          it { should be_truthy }
        end
        context "with resource not in scoped ability" do
          let(:category_id) { 2 }
          it { should be_truthy }
        end
      end
    end

    context "with custom attribute association restriction scoped by ability exception" do
      let(:resource_class) { Widget }
      let(:other_ability) { :suck }
      before do
        Cancannible.setup do |config|
          config.refine_access category_id: :category_ids, except: other_ability
        end
        allow(grantee).to receive(:category_ids).and_return([1,3])
        grantee.can(ability,resource_class)
        grantee.can(other_ability,resource_class)
      end
      let!(:resource) { resource_class.create(category_id: category_id) }
      context "when scoped ability" do
        subject { grantee.can?(ability,resource) }
        context "with resource within scope" do
          let(:category_id) { 3 }
          it { should be_truthy }
        end
        context "with resource not in scope" do
          let(:category_id) { 2 }
          it { should be_falsey }
        end
      end
      context "when other ability" do
        subject { grantee.can?(other_ability,resource) }
        context "with resource within scoped ability" do
          let(:category_id) { 3 }
          it { should be_truthy }
        end
        context "with resource not in scoped ability" do
          let(:category_id) { 2 }
          it { should be_truthy }
        end
      end
    end

    context "with custom attribute association restriction scoped by ability array" do
      let(:resource_class) { Widget }
      let(:other_ability) { :suck }
      before do
        Cancannible.setup do |config|
          config.refine_access category_id: :category_ids, scope: [ability,:another_ability]
        end
        allow(grantee).to receive(:category_ids).and_return([1,3])
        grantee.can(ability,resource_class)
        grantee.can(other_ability,resource_class)
      end
      let!(:resource) { resource_class.create(category_id: category_id) }
      context "when scoped ability" do
        subject { grantee.can?(ability,resource) }
        context "with resource within scope" do
          let(:category_id) { 3 }
          it { should be_truthy }
        end
        context "with resource not in scope" do
          let(:category_id) { 2 }
          it { should be_falsey }
        end
      end
      context "when other ability" do
        subject { grantee.can?(other_ability,resource) }
        context "with resource within scoped ability" do
          let(:category_id) { 3 }
          it { should be_truthy }
        end
        context "with resource not in scoped ability" do
          let(:category_id) { 2 }
          it { should be_truthy }
        end
      end
    end
    context "with if-conditional custom attribute association restriction" do
      let(:resource_class) { Widget }
      before do
        Cancannible.setup do |config|
          config.refine_access category_id: :category_ids, if: proc{ |grantee,model_resource| grantee.username == 'restrict by categories' }
        end
        allow(grantee).to receive(:category_ids).and_return([1,3])
        grantee.can(ability,resource_class)
      end
      let!(:resource) { resource_class.create(category_id: category_id) }
      subject { grantee.can?(ability,resource) }
      context "with resource not in scope but restriction not applicable" do
        let(:category_id) { 2 }
        it { should be_truthy }
      end
      context "with resource not in scope and restriction applicable" do
        let(:username) { 'restrict by categories' }
        let(:category_id) { 2 }
        it { should be_falsey }
      end
    end

    context "with combined attribute association and fixed value restriction" do
      let(:resource_class) { Widget }
      before do
        Cancannible.setup do |config|
          config.refine_access category_id: :category_ids, name: 'Test'
        end
        allow(grantee).to receive(:category_ids).and_return([1,3])
        grantee.can(ability,resource_class)
      end
      let!(:resource) { resource_class.create(category_id: category_id, name: name) }
      subject { grantee.can?(ability,resource) }
      context "with resource within scope" do
        let(:name) { 'Test' }
        let(:category_id) { 3 }
        it { should be_truthy }
      end
      context "with resource not in scope (excluded by attribute association)" do
        let(:name) { 'Test' }
        let(:category_id) { 2 }
        it { should be_falsey }
      end
      context "with resource not in scope (excluded by fixed value)" do
        let(:name) { 'Not Test' }
        let(:category_id) { 3 }
        it { should be_falsey }
      end
    end


  end

end
