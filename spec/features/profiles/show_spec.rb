# frozen_string_literal: true

require "rails_helper"

describe "Profile" do
  let(:profile) { create :profile }
  let(:user) { nil }

  before(:each) do
    sign_in user if user
    visit "/profiles/#{profile.id}".dup
  end

  it "does not permit access" do
    expect(page).to have_content("You are not authorized to perform this action.")
  end

  context "when user logged in" do
    let(:user) { create :user }

    it "shows the profile" do
      expect(page).to have_content "ChaelCodes"
      expect(page).not_to have_link "Edit", href: edit_profile_path(profile)
      expect(page).not_to have_button "Delete"
    end

    context "when user has a profile" do
      let(:current_profile) { create :profile }
      let(:user) { current_profile.user }

      it "allows user to befriend another" do
        expect(page).to have_button "Befriend"
        click_button "Befriend"
        expect(page).to have_content "Friendship was successfully created."
      end
    end

    context "when profile belongs to the user" do
      let(:user) { profile.user }

      it "allows user to edit profile" do
        expect(page).to have_link "Edit", href: edit_profile_path(profile)
        expect(page).to have_button "Delete"
      end
    end

    context "when user is admin" do
      let(:user) { create :user, :admin }

      it "allows user to destroy profile" do
        expect(page).not_to have_link "Edit", href: edit_profile_path(profile)
        expect(page).to have_button "Delete"
      end
    end
  end
end
