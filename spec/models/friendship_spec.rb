# frozen_string_literal: true

require "rails_helper"

RSpec.describe Friendship do
  let(:friendship) { create :friendship }

  it { expect(friendship).to be_valid }

  context "when buddy and friend are the same" do
    let(:friendship) { build :friendship, buddy: profile, friend: profile }
    let(:profile) { create :profile }

    it { expect(friendship).not_to be_valid }
  end

  describe "#create_notification" do
    subject { friendship } # create_notification is called in an after_create callback

    let(:friendship) { create :friendship, status: }
    let(:notification) { Notification.find_by(notifiable: friendship) }

    context "when profile is following a friend" do
      let(:status) { :accepted }

      it "does not create a new notification" do
        expect { subject }.not_to change(Notification, :count)
      end
    end

    context "when profile is blocking a 'friend'" do
      let(:status) { :blocked }

      it "does not create a new notification" do
        expect { subject }.not_to change(Notification, :count)
      end
    end

    context "when requesting a friend" do
      let(:status) { :requested }

      it "creates a new notification" do
        expect { subject }.to change(Notification, :count).by(1)
      end

      it "creates a notification for the friend request" do
        friendship # Creates Friendship and Notification
        expect(notification).to have_attributes(
          {
            message: "Chael wants to be friends with Chael!",
            profile: friendship.buddy
          }
        )
      end
    end
  end

  describe "#to_s" do
    subject { friendship.to_s }

    let(:buddy) { create :profile, name: "Xavier" }
    let(:friend) { create :profile, name: "Chael" }

    context "with accepted friendship" do
      let(:friendship) { create :friendship, :accepted, buddy:, friend: }

      it { is_expected.to eq "Xavier feels friendly towards Chael!" }
    end

    context "with blocked friendship" do
      let(:friendship) { create :friendship, :blocked, buddy:, friend: }

      it { is_expected.to eq "Xavier has blocked Chael." }
    end

    context "with requested friendship" do
      let(:friendship) { create :friendship, :requested, buddy:, friend: }

      it { is_expected.to eq "Chael wants to be friends with Xavier!" }
    end
  end
end
