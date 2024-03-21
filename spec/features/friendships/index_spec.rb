# frozen_string_literal: true

require "rails_helper"

describe "Friendships" do
  let!(:friendship) { create :friendship }
  let(:user) { nil }
  let(:path) { friendships_path }

  before(:each) do
    sign_in user if user
    visit path
  end

  it_behaves_like "unauthenticated user does not have access"

  context "when user logged in" do
    let(:user) { create :user }

    it "reminds the user to make a profile" do
      expect(page).to have_link "Make a Profile", href: new_profile_path
    end

    context "when user has a profile" do
      let(:profile) { create :profile, user: }
      let(:friendship) { create :friendship, buddy: profile, status: :accepted }

      it "shows the user's friends" do
        expect(page).to have_link friendship.friend.name, href: profile_path(friendship.friend)
        expect(page).to have_link "#{friendship.buddy.name} feels friendly towards #{friendship.friend.name}!",
                                  href: friendship_path(friendship)
      end

      context "with blocked friendships" do
        let!(:block_friendship) { create :friendship, friend: profile, status: :blocked }
        let!(:blocked_friendship) { create :friendship, buddy: profile, status: :blocked }

        it "hides blocked friendships" do
          visit current_path
          expect(page).not_to have_link block_friendship.buddy.name, href: profile_path(block_friendship.buddy)
          expect(page).not_to have_link blocked_friendship.friend.name, href: profile_path(blocked_friendship.friend)
        end
      end

      context "with a friend request" do
        let(:friendship) { create :friendship, buddy: profile, status: "requested" }

        it "accepts the friend request" do
          expect(page).to have_content "You have Friend Requests!"
          within ".friend-requests" do
            expect(page).to have_link friendship.friend.name, href: profile_path(friendship.friend)
            click_button("Accept friend request")
          end
          friendship.reload
          expect(friendship).to be_accepted
        end

        it "ignores the friend request" do
          expect(page).to have_content "You have Friend Requests!"
          within ".friend-requests" do
            expect(page).to have_link friendship.friend.name, href: profile_path(friendship.friend)
            click_button("Ignore")
          end
          expect { friendship.reload }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
