# frozen_string_literal: true

# Control permissions for the FriendshipPolicy
class FriendshipPolicy < ApplicationPolicy
  attr_reader :friendship

  def initialize(user, record)
    super
    @friendship = record
  end

  def index?
    true
  end

  def show?
    return true if my_friendship?
    @friendship.friend == current_profile && !@friendship.blocked?
  end

  def create?
    return true if missing_params # hit the validations instead of the authorizations
    return (@friendship.blocked? || @friendship.accepted?) if @friendship.buddy == @current_profile
    return @friendship.requested? if @friendship.friend == @current_profile
    false
  end

  def edit?
    user.admin? && Rails.env.development?
  end

  def new?
    false
  end

  def update?
    my_friendship?
  end

  def destroy?
    user.admin? || update?
  end

  def missing_params
    @friendship&.buddy.nil? || @friendship&.friend.nil? || @friendship&.status.nil?
  end

  def my_friendship?
    @current_profile == @friendship.buddy
  end

  # Permissions and access for a collection of Users
  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # TODO: Limit visibility of Friendships to yours
    def resolve
      scope.all
    end
  end
end
