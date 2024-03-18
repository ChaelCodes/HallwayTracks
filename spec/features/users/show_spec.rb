# frozen_string_literal: true

require "rails_helper"

describe "Users" do
  let(:user_profile) do
    create :user
  end

  before(:each) do
    sign_in user if user
    visit "/users/#{user_profile.id}".dup
  end

  context "when no user logged in" do
    let(:user) { nil }

    it "demands signup" do
      expect(page).to have_content "You need to sign in or sign up before continuing."
    end
  end

  context "when user is unconfirmed" do
    let(:user) { create :user, :unconfirmed }

    it "prompts the user to confirm email" do
      expect(page).to have_content "You have to confirm your email address before continuing."
    end
  end
end
