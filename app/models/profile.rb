# frozen_string_literal: true

# This Profile attends events and share information
# like bio, status, handle, twitch, YouTube, etc
# Becomes friends with other Profiles through Friendship
class Profile < ApplicationRecord
  include ::Handleable

  # Attributes
  enum visibility: {
    myself: 0,
    friends: 1,
    # attendees: 2,
    authenticated: 3,
    everyone: 4
  }, _prefix: :visible_to

  # Relationships
  belongs_to :user

  delegate :email, to: :user

  has_many :event_attendees, dependent: :destroy
  has_many :events, through: :event_attendees
  # Friendship has a buddy_id and a friend_id (These are both profiles)
  # We want friends to contain all of the profiles that are friends with the current profile
  # Whether they are "buddy" or "friend"
  has_many :friendships, class_name: "Friendship", foreign_key: "buddy_id", dependent: :destroy, inverse_of: :buddy
  # TODO: DELETE buddyships
  has_many :buddyships, class_name: "Friendship", foreign_key: "friend_id", dependent: :destroy, inverse_of: :friend

  def to_s
    name
  end

  def attending?(event)
    event_attendees.where(event:).any?
  end

  def event_attendee(event)
    event_attendees.where(event:)
  end

  # Profiles who are considered friends by this profile
  def friends
    Profile.where(id: friendships.accepted.select(:friend_id))
  end

  def friends_with?(profile)
    friends.include?(profile)
  end

  # TODO: Delete this
  def friendship_with(profile)
    Friendship.where(buddy_id: id, friend_id: profile.id)
              .or(Friendship.where(buddy_id: profile.id, friend_id: id)).first
  end

  # Friendship Requests for this Profile
  def friend_requests
    friendships.requested
  end
end
