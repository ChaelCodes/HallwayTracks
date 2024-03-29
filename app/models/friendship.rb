# frozen_string_literal: true

# This defines the relationship between two profiles.
class Friendship < ApplicationRecord
  include Rails.application.routes.url_helpers

  # I asked friend to be my buddy
  belongs_to :buddy, class_name: "Profile"
  # I was asked to become a friend by my buddy
  belongs_to :friend, class_name: "Profile"

  enum status: { accepted: 0, blocked: 1, requested: 2 }

  validates :status, presence: true

  after_create :create_notification

  def create_notification
    Notification.create(notifiable: self, profile: friend, url: friendship_url(self, only_path: true),
                        message: to_s)
  end

  # Returns whichever profile is not the passed profile
  # Returns nil if they're not one of the friends
  def not_my_profile(profile)
    return friend if profile.id == buddy_id
    buddy if profile.id == friend_id
  end

  def to_s
    case status
    when "accepted"
      "#{buddy} and #{friend} are friends!"
    when "blocked"
      "#{buddy} and #{friend} are NOT friends."
    when "requested"
      "#{buddy} wants to be friends with #{friend}!"
    end
  end
end
