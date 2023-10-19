# frozen_string_literal: true

require "rails_helper"

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to test the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator. If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails. There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.

RSpec.describe "/users" do
  # User. As you add validations to User, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) do
    {
      email: "chaelcodes@example.com",
      password: "password",
      name: "Chael",
      bio: "Hello. I am dev. Friends please? Ty."
    }
  end

  let(:user) { create :user }

  let(:json_body) do
    response.parsed_body.with_indifferent_access
  end

  let(:json_array) do
    response.parsed_body.map(&:with_indifferent_access)
  end

  before(:each) do
    sign_in user
  end

  describe "GET /index" do
    it "renders a successful response" do
      get users_url, params: { format: :json }
      expect(json_array.pluck(:id)).to include user.id
    end
  end

  describe "GET /show" do
    it "renders a successful response" do
      get user_url(user), params: { format: :json }
      expect(json_body).to include({
                                     bio: user.bio,
                                     name: user.name
                                   })
    end
  end

  describe "GET /new" do
    it "renders a successful response" do
      get new_user_url
      expect(response.body).to include("New User")
    end
  end

  describe "GET /edit" do
    it "render a successful response" do
      get edit_user_url(user)
      expect(response.body).to include "Editing User"
    end
  end

  describe "PATCH /update" do
    subject(:patch_update) { patch user_url(user), params: { user: attributes } }

    context "with valid parameters" do
      let(:attributes) do
        {
          name: "ChaelCodes"
        }
      end

      it "updates the requested user" do
        patch_update
        user.reload
        expect(user.name).to eq "ChaelCodes"
      end

      it "redirects to the user" do
        patch_update
        expect(response).to redirect_to(user_url(user))
      end
    end
  end

  describe "DELETE /destroy" do
    it "destroys the requested user" do
      expect do
        delete user_url(user)
      end.to change(User, :count).by(-1)
    end

    it "redirects to the users list" do
      delete user_url(user)
      expect(response).to redirect_to(users_url)
    end
  end
end
