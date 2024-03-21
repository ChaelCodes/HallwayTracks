# frozen_string_literal: true

# Control permissions for the Profile
class ProfilePolicy < ApplicationPolicy
  attr_reader :profile

  def initialize(user, record)
    super
    @profile = record
  end

  def index?
    confirmed_user?
  end

  # Whether the user can view the Profile's Handle, Bio, and Avatar.
  def show?
    return true if mine? || admin? || profile.visible_to_everyone?
    confirmed_user?
  end

  # This method controls whether a user can view a profile's details.
  # The details include the bio and event attendance.
  # Admins can always view profiles. Users can view their own profiles.
  # Profiles can set their own visibility.
  # * Everyone - anyone can view
  # * Authenticated - only logged in, and confirmed users can view
  # * Friends - only accepted friends can view
  # * Myself - only the user can view - NOT EVEN EXISTING FRIENDS!
  def show_details?
    return true if mine? || admin? || profile.visible_to_everyone?
    return confirmed_user? if profile.visible_to_authenticated?
    profile.friends_with? current_profile if profile.visible_to_friends?
  end

  def create?
    true
  end

  def update?
    mine?
  end

  def destroy?
    mine? || admin?
  end

  # Permissions and access for a collection of Profiles
  class Scope
    attr_reader :current_profile, :user, :scope

    AUTHENTICATED_ACCESS = %i[everyone authenticated].freeze
    UNAUTHENTICATED_ACCESS = :everyone

    def initialize(user, scope)
      @user = user
      @scope = scope
      @current_profile = user&.profile
    end

    def resolve
      collection = current_profile ? except_people_who_dont_like_you : scope
      respecting_profile_visibility(collection)
    end

    private

    def public_access_list
      user&.confirmed? ? AUTHENTICATED_ACCESS : UNAUTHENTICATED_ACCESS
    end

    def except_people_who_dont_like_you
      scope.where.not(id: Friendship.blocks(current_profile).select(:buddy_id))
    end

    def respecting_profile_visibility(collection)
      profiles = collection.where(visibility: public_access_list)
      return profiles unless current_profile
      profiles.or(collection.where(id: Friendship.friends_of(current_profile).select(:buddy_id),
                                   visibility: :friends))
              .or(collection.where(id: current_profile.id))
    end
  end
end
