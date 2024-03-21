# frozen_string_literal: true

require "rails_helper"

# Describes the FriendshipHelper
RSpec.describe FriendshipsHelper do
  describe "#accept_friendship_button" do
    subject { accept_friendship_button(friendship, current_profile) }

    let(:current_user) { create :user }
    let(:current_profile) { create :profile, user: current_user }

    context "when no one wants to be your friend" do
      let(:friendship) { build :friendship, status: :requested, buddy: current_profile }

      it { is_expected.to be_nil }
    end

    context "when you have requested friendship" do
      let(:friendship) { create :friendship, friend: current_profile, status: :requested }

      it { is_expected.to be_nil }
    end

    context "when they are friendly with you" do
      let!(:friendship) { create :friendship, buddy: current_profile, status: :accepted }

      it { is_expected.to be_nil }
    end

    context "when your friendship is requested" do
      let!(:friendship) { create :friendship, buddy: current_profile, status: :requested }

      it "allows you to accept Friend Request" do
        is_expected.to match(/Accept friend request/)
      end

      context "when they are already friends with you" do
        let!(:their_friendship) { create :friendship, friend: current_profile, status: :accepted }

        it "allows you to accept Friend Request" do
          is_expected.to match(/Accept friend request/)
        end
      end
    end
  end

  describe "#befriend_button" do
    subject { befriend_button(friendship, current_profile) }

    let(:current_user) { create :user }
    let(:current_profile) { create :profile, user: current_user }

    context "when you are already friendly" do
      let(:friendship) { create :friendship, buddy: current_profile, status: :accepted }

      it { is_expected.to be_nil }
    end

    context "when you're not friendly yet" do
      let(:friendship) { build :friendship, buddy: current_profile, status: :accepted }

      it { is_expected.to match(/Befriend/) }
    end

    context "when you're the friend, not the buddy" do
      let(:friendship) { create :friendship, friend: current_profile, status: :accepted }

      it { is_expected.to be_nil }
    end
  end

  describe "#block_button" do
    subject { block_button(friendship, current_profile) }

    let(:current_user) { create :user }
    let(:current_profile) { create :profile, user: current_user }

    context "with existing friendship" do
      let(:friendship) { create :friendship, buddy: current_profile }

      it { is_expected.to match(/Block/) }
    end

    context "with no friendship" do
      let(:friendship) { build :friendship, buddy: current_profile }

      it { is_expected.to match(/Block/) }
    end

    context "when you have blocked them" do
      let(:friendship) { create :friendship, buddy: current_profile, status: :blocked }

      it { is_expected.to be_nil }
    end

    context "when it's not your friendship" do
      let(:friendship) { create :friendship, friend: current_profile }

      it { is_expected.to be_nil }
    end
  end

  describe "#destroy_friendship_button" do
    subject { destroy_friendship_button(friendship, current_profile) }

    let(:current_user) { create :user }
    let(:current_profile) { create :profile, user: current_user }

    context "when it's not your friendship" do
      let(:friendship) { create :friendship }

      it { is_expected.to be_nil }
    end

    context "when friendship isn't saved" do
      let(:friendship) { build :friendship, buddy: current_profile }

      it { is_expected.to be_nil }
    end

    context "when friendship is accepted" do
      let(:friendship) { create :friendship, buddy: current_profile, status: :accepted }

      it { is_expected.to match(/Unfriend/) }
    end

    context "when friendship is blocked" do
      let(:friendship) { create :friendship, buddy: current_profile, status: :blocked }

      it { is_expected.to match(/Unblock/) }
    end

    context "when friendship is requested" do
      let(:friendship) { create :friendship, buddy: current_profile, status: :requested }

      it { is_expected.to match(/Ignore/) }
    end
  end

  describe "#request_friend_button" do
    subject { request_friend_button(friendship, current_profile) }

    let(:current_user) { create :user }
    let(:current_profile) { create :profile, user: current_user }

    context "when friendship already exists" do
      let(:friendship) { create :friendship, friend: current_profile }

      it { is_expected.to be_nil }

      context "when it is my friendship" do
        let(:friendship) { create :friendship, buddy: current_profile }

        it { is_expected.to be_nil }
      end
    end

    context "when friendship does not exist" do
      let(:friendship) { build :friendship, friend: current_profile }

      it { is_expected.to match(/Request Friend/) }

      context "when it is my friendship" do
        let(:friendship) { build :friendship, buddy: current_profile }

        it { is_expected.to be_nil }
      end
    end
  end
end
