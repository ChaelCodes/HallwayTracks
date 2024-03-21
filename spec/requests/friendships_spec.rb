# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/friendships" do
  let(:friendship) { create :friendship, buddy:, friend: }
  let(:buddy) { create :profile }
  let(:friend) { create :profile }
  let(:user) { nil }

  before(:each) do
    sign_in user if user
  end

  describe "GET /index" do
    subject(:get_index) { get friendships_url }

    before(:each) { friendship }

    include_examples "redirect to sign in"

    context "when user is signed in" do
      let(:user) { create :user }

      it "renders a successful response" do
        get_index
        expect(response).to be_successful
      end

      context "when user has profile" do
        let!(:profile) { create :profile, user: }

        it "renders a successful response" do
          get_index
          expect(response).to be_successful
        end
      end
    end
  end

  describe "GET /show" do
    subject(:get_show) { get friendship_url(friendship) }

    include_examples "redirect to sign in"

    context "when user is signed in" do
      let(:user) { create :user }

      include_examples "unauthorized access"
    end

    context "when the user is a friend" do
      let(:user) { friendship.friend.user }

      it "renders a successful response" do
        get_show
        expect(response).to be_successful
      end
    end
  end

  describe "GET /new" do
    subject(:get_new) { get new_friendship_url }

    include_examples "redirect to sign in"

    context "with logged in user" do
      let(:user) { create :user }

      include_examples "unauthorized access"
    end
  end

  describe "GET /edit" do
    subject(:get_edit) { get edit_friendship_url(friendship) }

    include_examples "redirect to sign in"

    context "with logged in user" do
      let(:user) { create :user }

      include_examples "unauthorized access"
    end

    context "with buddy" do
      let(:user) { friendship.buddy.user }

      include_examples "unauthorized access"
    end

    context "with friend" do
      let(:user) { friendship.friend.user }

      include_examples "unauthorized access"
    end
  end

  describe "POST /create" do
    subject(:post_create) { post friendships_url, params: { friendship: attributes } }

    context "with valid parameters" do
      let(:attributes) { { buddy_id: buddy.id, friend_id: friend.id, status: "accepted" } }

      include_examples "redirect to sign in"

      context "with logged in user" do
        let(:user) { buddy.user }

        it "creates a new Friendship" do
          expect { post_create }.to change(Friendship, :count).by(1)
        end

        it "redirects to the created friendship" do
          post_create
          expect(response).to redirect_to(friendship_url(Friendship.order(:created_at).last))
        end
      end
    end

    context "with invalid parameters" do
      let(:attributes) { attributes_for :friendship, friend_id: nil }
      let(:user) { buddy.user }

      it "does not create a new Friendship" do
        expect { post_create }.not_to change(Friendship, :count)
      end

      it "returns an unprocessable entity code" do
        post_create
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    subject(:patch_update) { patch friendship_url(friendship), params: { friendship: attributes } }

    before(:each) { friendship }

    context "with valid parameters" do
      let(:attributes) { { status: "accepted" } }

      include_examples "redirect to sign in"

      context "with logged in user" do
        let(:user) { create :user }

        include_examples "unauthorized access"

        context "with buddy" do
          let(:user) { buddy.user }

          it "updates the requested friendship" do
            patch_update
            friendship.reload
            expect(friendship.status).to eq("accepted")
          end

          it "redirects to the friendship" do
            patch_update
            expect(response).to redirect_to(friendship_url(friendship))
          end
        end

        context "with friend" do
          let(:user) { friend.user }

          include_examples "unauthorized access"
        end
      end
    end

    context "with invalid parameters" do
      let(:attributes) { attributes_for :friendship, status: nil }
      let(:user) { buddy.user }

      it "returns an unprocessable entity code" do
        patch_update
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    subject(:delete_destroy) { delete friendship_url(friendship) }

    before(:each) { friendship }

    include_examples "redirect to sign in"

    context "with logged in user" do
      let(:user) { create :user }

      include_examples "unauthorized access"
    end

    context "with buddy" do
      let(:user) { buddy.user }

      it "destroys the requested friendship" do
        expect { delete_destroy }.to change(Friendship, :count).by(-1)
      end

      it "redirects to the friendships list" do
        delete_destroy
        expect(response).to redirect_to(friendships_url)
      end
    end

    context "with admin" do
      let(:user) { create :user, :admin }

      it "destroys the requested friendship" do
        expect { delete_destroy }.to change(Friendship, :count).by(-1)
      end

      it "redirects to the friendships list" do
        delete_destroy
        expect(response).to redirect_to(friendships_url)
      end
    end
  end
end
