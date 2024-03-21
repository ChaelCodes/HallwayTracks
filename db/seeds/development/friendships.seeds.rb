# frozen_string_literal: true

after "development:profiles" do
  # Establish friendships between first 10 Profiles
  profiles = Profile.first(10)

  profiles.each_cons(3) do |request_profile, profile, friend_profile|
    Friendship.create_with(status: :accepted).find_or_create_by!(buddy_id: profile.id, friend_id: friend_profile.id)
    Friendship.create_with(status: :requested).find_or_create_by!(buddy_id: request_profile.id, friend_id: profile.id)
  end

  [
    { buddy_id: profiles[0].id, friend_id: profiles.last.id, status: :accepted },
    { buddy_id: profiles.last.id, friend_id: profiles[0].id, status: :requested }
  ].each do |friendship|
    Friendship.create_with(friendship)
              .find_or_create_by!(buddy_id: friendship[:buddy_id], friend_id: friendship[:friend_id])
  end
end
