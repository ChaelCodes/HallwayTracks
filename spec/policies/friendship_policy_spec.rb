# frozen_string_literal: true

require "rails_helper"

describe FriendshipPolicy, type: :policy do
  permissions :show? do
    let(:friendship) { create :friendship }

    context "with no User" do
      let(:user) { nil }

      it { expect(described_class).not_to permit(user, friendship) }
    end

    context "with random confirmed user" do
      let(:profile) { create :profile }
      let(:user) { profile.user }

      it { expect(described_class).not_to permit(user, friendship) }
    end

    context "with friendship's buddy" do
      let(:user) { friendship.buddy.user }

      it { expect(described_class).to permit(user, friendship) }
    end

    context "with friendship's friend" do
      let(:user) { friendship.friend.user }

      it { expect(described_class).to permit(user, friendship) }

      context "when the buddy has blocked friend" do
        let(:friendship) { create :friendship, status: :blocked }

        it { expect(described_class).not_to permit(user, friendship) }
      end
    end
  end
end
