# frozen_string_literal: true

require "rails_helper"

describe ProfilePolicy, type: :policy do
  permissions :index? do
    context "with no User" do
      let(:user) { nil }

      it { expect(described_class).not_to permit(user, :index?) }
    end

    context "with unconfirmed User" do
      let(:user) { build :user, :unconfirmed_with_trial }

      it { expect(described_class).not_to permit(user, :index?) }
    end

    context "with confirmed user" do
      let(:user) { build :user }

      it { expect(described_class).to permit(user, :index?) }
    end
  end

  permissions :show_details? do
    context "with viewing everyone profile" do
      let(:profile) { build :profile, visibility: :everyone }

      context "with no user" do
        it { expect(described_class).to permit(nil, profile) }
      end

      context "with unconfirmed user" do
        let(:user) { create :user, :unconfirmed }

        it { expect(described_class).to permit(user, profile) }
      end

      context "with confirmed user" do
        let(:user) { create :user }

        it { expect(described_class).to permit(user, profile) }
      end

      context "with admin" do
        let(:user) { create :user, :admin }

        it { expect(described_class).to permit(user, profile) }
      end
    end

    context "when viewing authenticated profile" do
      let(:profile) { build :profile, visibility: :authenticated }

      context "with no user" do
        it { expect(described_class).not_to permit(nil, profile) }
      end

      context "with unconfirmed user" do
        let(:user) { create :user, :unconfirmed }

        it { expect(described_class).not_to permit(user, profile) }
      end

      context "with confirmed user" do
        let(:user) { create :user }

        it { expect(described_class).to permit(user, profile) }
      end

      context "with admin" do
        let(:user) { create :user, :admin }

        it { expect(described_class).to permit(user, profile) }
      end
    end

    context "when viewing friends profile" do
      let(:profile) { build :profile, visibility: :friends }

      context "with no user" do
        it { expect(described_class).not_to permit(nil, profile) }
      end

      context "with unconfirmed user" do
        let(:user) { create :user, :unconfirmed }

        it { expect(described_class).not_to permit(user, profile) }

        context "when profile is my friend" do
          let(:current_profile) { create :profile, user: }
          let!(:friendship) { create :friendship, buddy: profile, friend: current_profile, status: :accepted }

          it { expect(described_class).to permit(user, profile) }
        end

        context "when I have friended profile" do
          let(:current_profile) { create :profile, user: }
          let!(:friendship) { create :friendship, buddy: current_profile, friend: profile, status: :accepted }

          it { expect(described_class).not_to permit(user, profile) }
        end
      end

      context "with confirmed user" do
        let(:user) { create :user }

        it { expect(described_class).not_to permit(user, profile) }
      end

      context "with admin" do
        let(:user) { create :user, :admin }

        it { expect(described_class).to permit(user, profile) }
      end
    end

    context "when viewing myself profile" do
      let(:profile) { build :profile, visibility: :myself }

      context "with no user" do
        it { expect(described_class).not_to permit(nil, profile) }
      end

      context "with unconfirmed user" do
        let(:user) { create :user, :unconfirmed }

        it { expect(described_class).not_to permit(user, profile) }

        context "when profile is my own" do
          let(:profile) { create :profile, user:, visibility: :myself }

          it { expect(described_class).to permit(user, profile) }
        end
      end

      context "with confirmed user" do
        let(:user) { create :user }

        it { expect(described_class).not_to permit(user, profile) }

        context "when profile is my own" do
          let(:profile) { create :profile, user:, visibility: :myself }

          it { expect(described_class).to permit(user, profile) }
        end
      end

      context "with admin" do
        let(:user) { create :user, :admin }

        it { expect(described_class).to permit(user, profile) }
      end
    end
  end

  permissions ".scope?" do
    subject { Pundit.policy_scope(user, Profile.all).pluck(:visibility) }

    let!(:myself) { create :profile, visibility: :myself }
    let!(:friends) { create :profile, visibility: :friends }
    let!(:authenticated) { create :profile, visibility: :authenticated }
    let!(:everyone) { create :profile, visibility: :everyone }

    context "with no user" do
      let(:user) { nil }

      it { is_expected.to contain_exactly("everyone") }
    end

    context "with unconfirmed user" do
      let(:user) { create :user, :unconfirmed }
      let(:current_profile) { create :profile, user:, visibility: :myself }

      it { is_expected.to contain_exactly("everyone") }

      context "when friends profile is friendly with you" do
        let!(:friendship) { create :friendship, buddy: friends, friend: current_profile, status: :accepted }

        it { is_expected.to match_array %w[everyone friends myself] }
      end

      context "when you are friendly with friends profile" do
        let!(:friendship) { create :friendship, buddy: current_profile, friend: friends, status: :accepted }

        it { is_expected.to match_array %w[everyone myself] }
      end

      context "when you are blocked" do
        let!(:blocked_by_friends) { create :friendship, buddy: friends, friend: current_profile, status: :blocked }
        let!(:blocked_by_everyone) { create :friendship, buddy: everyone, friend: current_profile, status: :blocked }

        it { is_expected.to contain_exactly("myself") }
      end
    end

    context "with confirmed user" do
      let(:user) { create :user }
      let(:current_profile) { create :profile, user:, visibility: :myself }

      it { is_expected.to match_array %w[everyone authenticated] }

      context "when friends profile is friendly with you" do
        let!(:friendship) { create :friendship, buddy: friends, friend: current_profile, status: :accepted }

        it { is_expected.to match_array %w[everyone authenticated friends myself] }
      end

      context "when you are friendly with friends profile" do
        let!(:friendship) { create :friendship, buddy: current_profile, friend: friends, status: :accepted }

        it { is_expected.to match_array %w[everyone authenticated myself] }
      end

      context "when you are blocked" do
        let!(:blocked_by_friends) { create :friendship, buddy: friends, friend: current_profile, status: :blocked }
        let!(:blocked_by_authenticated) do
          create :friendship, buddy: authenticated, friend: current_profile, status: :blocked
        end
        let!(:blocked_by_everyone) { create :friendship, buddy: everyone, friend: current_profile, status: :blocked }

        it { is_expected.to contain_exactly("myself") }
      end
    end

    context "with admin" do
      let(:user) { create :user, :admin }

      it { is_expected.to match_array %w[everyone authenticated] }
    end
  end
end
