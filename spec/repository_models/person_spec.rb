require 'spec_helper'

describe Person do

  describe 'associated with a user' do
    subject { FactoryGirl.create(:person_with_user) }
    its(:user) { should be_instance_of User }
    it '#profile' do
      expect(subject.profile).to be_instance_of Collection
      expect(subject.profile.depositor).to eq subject.user.to_s
      expect(subject.profile.title).to_not be_nil
      expect(subject.profile.read_groups).to eq [Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC]
    end
  end

  describe 'not associated with a user' do
    subject { FactoryGirl.create(:person) }
    its(:user) { should be_nil }
  end

  describe 'to_solr' do
    let(:solr_doc) {subject.to_solr}
    it "should have a generic_type" do
      solr_doc['generic_type_sim'].should == ['Person']
    end
  end

end
