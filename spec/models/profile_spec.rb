# frozen_string_literal: true

require "rails_helper"

RSpec.describe Profile do
  let(:profile) { create :profile }

  describe "validations" do
    it "has a valid factory" do
      expect(profile).to be_valid
    end

    context "with duplicate handle" do
      let(:duplicate_handle) { build :profile, handle: profile.handle.downcase }

      it "does not allow two profiles to have the same handle" do
        profile
        duplicate_handle.valid?
        expect(duplicate_handle.errors.full_messages).to include("Handle has already been taken")
      end
    end
  end

  describe "#attending?" do
    subject { profile.attending? event }

    let(:event) { create :event }

    it { is_expected.to be_falsey }

    context "when profile is attending" do
      let!(:event_attendee) { create :event_attendee, profile:, event: }

      it { is_expected.to be_truthy }
    end
  end

  describe "#friends" do
    subject { profile.friends }

    let(:friend) { create :profile }

    it { is_expected.to be_empty }

    context "when profile has friends" do
      let!(:friendship) { Friendship.create(friend:, buddy: profile, status: :accepted) }

      it { is_expected.to include(friend) }
    end

    context "when the profile has blocked a 'friend'" do
      let!(:friendship) { Friendship.create(friend:, buddy: profile, status: :blocked) }

      it { is_expected.not_to include(friend) }
    end

    context "when profile has requested a friend" do
      let!(:friendship) { Friendship.create(friend:, buddy: profile, status: :requested) }

      it "does not include friend requests" do
        is_expected.not_to include(friend)
      end
    end

    context "when profile has pending friend requests" do
      let!(:friendship2) { Friendship.create(friend:, buddy: profile, status: :requested) }

      it "does not include friend requests" do
        is_expected.not_to include(friend)
      end
    end
  end

  describe "#friendship_with" do
    subject { profile.friendship_with(friend) }

    let(:friend) { create :profile }

    it { is_expected.to be_nil }

    context "when profile is the buddy" do
      let!(:friendship) { create :friendship, buddy: profile, friend: }

      it { is_expected.to eq friendship }
    end

    context "when the profile is the friend" do
      let!(:friendship) { create :friendship, buddy: friend, friend: profile }

      it { is_expected.to eq friendship }
    end
  end
end
