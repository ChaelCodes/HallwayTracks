# frozen_string_literal: true

# methods to help with displaying friendship!
module FriendshipsHelper
  # Show likely Friendship options
  def friendship_button(friendship, current_profile)
    return nil unless friendship && current_profile
    safe_join([
      accept_friendship_button(friendship, current_profile),
      befriend_button(friendship, current_profile),
      destroy_friendship_button(friendship, current_profile),
      request_friend_button(friendship, current_profile),
      block_button(friendship, current_profile)
    ].compact)
  end

  # Accept a Friendship Request
  def accept_friendship_button(friendship, current_profile)
    return nil unless friendship&.requested? && friendship&.persisted?
    return nil unless friendship&.buddy == current_profile
    button_to "Accept friend request", friendship_path(friendship, {
                                                         friendship: {
                                                           status: :accepted
                                                         }
                                                       }), form_class: "control",
                                                           method: :put,
                                                           class: "button is-success is-outlined"
  end

  def befriend_button(friendship, current_profile)
    return nil if friendship.persisted?
    return nil unless friendship.buddy == current_profile
    button_to "Befriend",
              friendships_path(friendship: {
                                 friend_id: friendship.friend_id,
                                 buddy_id: friendship.buddy_id,
                                 status: :accepted
                               }), form_class: "control",
                                   method: :post,
                                   class: "button is-success"
  end

  # Block a Friendship - Create if no Friendship exists, Update if it does
  def block_button(friendship, current_profile)
    return nil if friendship.blocked?
    return nil unless friendship.buddy == current_profile
    button_to "Block", friendship,
              params: { friendship: {
                status: :blocked,
                buddy_id: friendship.buddy_id,
                friend_id: friendship.friend_id
              } },
              form_class: "control",
              class: "button is-danger is-outlined"
  end

  # This displays a button to destroy the friendship
  def destroy_friendship_button(friendship, current_profile)
    return unless current_profile == friendship.buddy
    return unless friendship.persisted?
    button_names = { "accepted" => "Unfriend", "blocked" => "Unblock", "requested" => "Ignore" }
    button_to button_names[friendship.status],
              friendship_path(friendship),
              form_class: "control",
              class: "button is-warning is-outlined",
              method: :delete
  end

  # Request the Friendship of another user
  def request_friend_button(friendship, current_profile)
    return if friendship.persisted?
    return unless friendship.friend == current_profile
    button_to "Request Friend",
              friendships_path(friendship: {
                                 friend_id: friendship.friend_id,
                                 buddy_id: friendship.buddy_id,
                                 status: "requested"
                               }), method: :post,
                                   form_class: "control",
                                   class: "button is-primary is_outlined"
  end

  def view_friendship(friendship)
    link_to friendship
  end
end
