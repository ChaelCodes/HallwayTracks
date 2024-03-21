# frozen_string_literal: true

require "rails_helper"

RSpec.describe "/profiles" do
  let(:profile) { create :profile }
  let(:json_headers) { { ACCEPT: "application/json" } }

  # Test all routes as an authenticated user
  let(:user) { create :user }

  before(:each) do
    sign_in user if user
  end

  # rubocop:disable RSpec/MultipleExpectations
  describe "GET /index" do
    subject(:get_index) { get profiles_url, params: { format: :json } }

    let!(:everyone_profile) { create :profile, visibility: :everyone }
    let!(:authenticated_profile) { create :profile, visibility: :authenticated }
    let!(:not_friends_profile) { create :profile, visibility: :friends }
    let!(:friends_profile) { create :profile, visibility: :friends }
    let!(:myself_profile) { create :profile, visibility: :myself }
    let!(:current_profile) { create :profile, user:, visibility: :myself }
    let!(:friendship) { create :friendship, buddy: friends_profile, friend: current_profile, status: :accepted }

    context "when the profile belongs to a confirmed user" do
      it "renders a successful response" do
        get_index
        handles = json_body.pluck("handle")
        expect(handles).to include(everyone_profile.handle)
        expect(handles).to include(authenticated_profile.handle)
        expect(handles).not_to include(not_friends_profile.handle)
        expect(handles).not_to include(myself_profile.handle)
        expect(handles).to include(friends_profile.handle)
        expect(handles).to include(current_profile.handle)
      end
    end

    context "when the profile belongs to an unconfirmed user in the grace period" do
      let(:user) { create :user, :unconfirmed_with_trial }

      it "shows only public profiles" do
        get_index
        handles = json_body.pluck("handle")
        expect(handles).to include(everyone_profile.handle)
        expect(handles).not_to include(authenticated_profile.handle)
        expect(handles).not_to include(not_friends_profile.handle)
        expect(handles).not_to include(myself_profile.handle)
        expect(handles).to include(friends_profile.handle)
        expect(handles).to include(current_profile.handle)
      end
    end

    context "when the profile belongs to an overdue unconfirmed user" do
      subject(:get_index) { get profiles_url, params: { format: :html } }

      let(:user) { create :user, :overdue_unconfirmed }

      it_behaves_like "confirm your email"
    end
  end
  # rubocop:enable RSpec/MultipleExpectations

  describe "GET /show" do
    subject(:get_show) { get profile_url(profile), headers: }

    let(:headers) { nil }

    it_behaves_like "show page renders a sucessful response"

    context "when the profile is attending events" do
      let(:headers) { json_headers }
      let!(:event_attendee) { create :event_attendee, profile: }

      shared_examples "shows events" do
        it "send events" do
          get_show
          expect(response.parsed_body["events"].first["id"]).to eq(event_attendee.event.id)
        end
      end

      shared_examples "won't show events" do
        it "don't send events" do
          get_show
          expect(response.parsed_body["events"]).to be_empty
        end
      end

      it_behaves_like "shows events"

      context "when profile is everyone" do
        let(:profile) { create :profile, visibility: :everyone }

        it_behaves_like "shows events"
      end

      context "when profile is authenticated" do
        let(:profile) { create :profile, visibility: :authenticated }

        it_behaves_like "shows events"
      end

      context "when profile is friends" do
        let(:profile) { create :profile, visibility: :friends }

        it_behaves_like "won't show events"
      end

      context "when profile is myself" do
        let(:profile) { create :profile, visibility: :myself }

        it_behaves_like "won't show events"
      end
    end

    context "when profile is visible to everyone" do
      let(:profile) { create :profile, visibility: :everyone }

      context "when user is not signed in" do
        let(:user) { nil }

        it_behaves_like "show page renders a sucessful response"
      end
    end

    context "when profile is visible to authenticated" do
      let(:profile) { create :profile, visibility: :authenticated }

      context "when user is not signed in" do
        let(:user) { nil }

        it_behaves_like "unauthorized access"
      end

      context "when user is signed in" do
        let(:user)  { create :user, :unconfirmed_with_trial }

        it_behaves_like "unauthorized access"
      end

      context "when user has confirmed their email" do
        let(:user)  { create :user }

        it_behaves_like "show page renders a sucessful response"
      end

      context "when user is me" do
        let(:user)  { profile.user }

        it_behaves_like "show page renders a sucessful response"
      end
    end

    context "when profile is visible to friends" do
      let(:profile) { create :profile, visibility: :friends }

      context "when user is signed in but unconfirmed" do
        let(:user)  { create :user, :unconfirmed_with_trial }

        it_behaves_like "unauthorized access"
      end

      context "when user is your friend" do
        let(:user) { friendship.buddy.user }
        let(:friendship) { create :friendship, friend: profile, status: :accepted }

        it_behaves_like "show page renders a sucessful response"
      end

      context "when user is not your friend" do
        let(:user) { friendship.buddy.user }
        let(:friendship) { create :friendship, friend: profile, status: :requested }

        it_behaves_like "show page renders a sucessful response"
      end

      context "when user is me" do
        let(:user)  { profile.user }

        it_behaves_like "show page renders a sucessful response"
      end
    end

    context "when profile is visible to myself" do
      let(:profile) { create :profile, visibility: :myself }

      context "when user is signed in but unconfirmed" do
        let(:user)  { create :user, :unconfirmed_with_trial }

        it_behaves_like "unauthorized access"
      end

      context "when user is friend" do
        let(:user) { friendship.buddy.user }
        let(:friendship) { create :friendship, friend: profile, status: :accepted }

        it_behaves_like "show page renders a sucessful response"
      end

      context "when user is signed in" do
        let(:user)  { create :user }

        it_behaves_like "show page renders a sucessful response"
      end

      context "when user is me" do
        let(:user)  { profile.user }

        it_behaves_like "show page renders a sucessful response"
      end

      context "when user is admin" do
        let(:user)  { create :user, :admin }

        it_behaves_like "show page renders a sucessful response"
      end
    end
  end

  describe "GET /show with handle" do
    subject(:get_show) { get "/profiles/#{profile.handle}" }

    it "renders a successful response" do
      get_show
      expect(response).to be_successful
    end
  end

  describe "GET /new" do
    subject(:get_new) { get new_profile_url }

    it "renders a successful response" do
      get new_profile_url
      expect(response).to be_successful
    end
  end

  describe "GET /edit" do
    subject(:get_edit) { get edit_profile_url(profile) }

    it "redirects unauthorized user" do
      get_edit
      expect(response).to redirect_to(root_path)
    end

    context "when user edits their profile" do
      let(:user) { profile.user }

      it "render a successful response" do
        get_edit
        expect(response).to be_successful
      end
    end
  end

  describe "POST /create" do
    subject(:post_create) { post profiles_url, params: { profile: attributes } }

    context "with valid parameters" do
      let(:attributes) do
        {
          handle: "ChaelCodes"
        }
      end

      it "creates a new Profile" do
        expect { post_create }.to change(Profile, :count).by(1)
      end

      it "redirects to the created profile" do
        post_create
        expect(response).to redirect_to(profile_url(Profile.last))
      end

      context "with uncofirmed user in trial period" do
        let(:user) { create :user, :unconfirmed_with_trial }

        it "creates a new Profile" do
          expect { post_create }.to change(Profile, :count).by(1)
        end

        it "redirects to the created profile" do
          post_create
          expect(response).to redirect_to(profile_url(Profile.last))
        end
      end

      context "with overdue_unconfirmed user" do
        let(:user) { create :user, :overdue_unconfirmed }

        it_behaves_like "confirm your email"
      end
    end

    context "with invalid parameters" do
      let(:attributes) { { handle: "" } }

      it "does not create a new Profile" do
        expect { post_create }.not_to change(Profile, :count)
      end

      it "returns an unprocessable entity code" do
        post_create
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "PATCH /update" do
    subject(:patch_update) do
      patch profile_url(profile), params: { profile: attributes }
    end

    context "with valid parameters" do
      let(:attributes) do
        { handle: "ChaelChats" }
      end

      it "redirects unauthorized user" do
        patch_update
        expect(response).to redirect_to(root_path)
      end

      context "with the profile's creator" do
        let(:user) { profile.user }

        it "updates the requested profile" do
          patch_update
          profile.reload
          expect(profile.handle).to eq "ChaelChats"
        end

        it "redirects to the profile" do
          patch_update
          profile.reload
          expect(response).to redirect_to(profile_url(profile))
        end
      end

      context "with admin" do
        let(:profile) { create :profile, handle: "Foo" }
        let(:user) { create :user, :admin }

        include_examples "unauthorized access"

        it "does not update the profile" do
          patch_update
          profile.reload
          expect(profile.handle).to eq "Foo"
        end
      end
    end

    context "with invalid parameters" do
      let(:attributes) { { handle: "" } }
      let(:user) { profile.user }

      it "returns an unprocessable entity code" do
        patch_update
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /destroy" do
    subject(:delete_destroy) { delete profile_url(profile) }

    let!(:profile) { create :profile }

    include_examples "unauthorized access"

    context "with profile's creator" do
      let(:user) { profile.user }

      it "destroys the requested profile" do
        expect { delete_destroy }.to change(Profile, :count).by(-1)
      end

      it "redirects to the profiles list" do
        delete_destroy
        expect(response).to redirect_to(profiles_url)
      end
    end

    context "with an admin" do
      let(:user) { create :user, :admin }

      it "destroys the requested profile" do
        expect { delete_destroy }.to change(Profile, :count).by(-1)
      end

      it "redirects to the profiles list" do
        delete_destroy
        expect(response).to redirect_to(profiles_url)
      end
    end
  end
end
