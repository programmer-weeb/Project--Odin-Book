require "test_helper"

class UserTest < ActiveSupport::TestCase
  test ".from_google_oauth links existing user by verified email" do
    existing_user = users(:one)

    auth = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "google-123",
      info: {
        email: existing_user.email,
        email_verified: true,
        name: "Existing User"
      }
    )

    user = User.from_google_oauth(auth)

    assert_equal existing_user, user
    assert_equal "google_oauth2", user.provider
    assert_equal "google-123", user.uid
  end

  test ".from_google_oauth creates user with Google profile data" do
    auth = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "google-456",
      info: {
        email: "new-google-user@example.com",
        email_verified: true,
        name: "New Google User"
      }
    )

    user = nil
    assert_difference("User.count", 1) do
      user = User.from_google_oauth(auth)
    end

    assert_equal "new-google-user@example.com", user.email
    assert_equal "google_oauth2", user.provider
    assert_equal "google-456", user.uid
    assert_equal "New Google User", user.profile.display_name
  end

  test ".from_google_oauth rejects unverified email" do
    auth = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: "google-789",
      info: {
        email: "unverified@example.com",
        email_verified: false,
        name: "Unverified User"
      }
    )

    error = assert_raises(ArgumentError) { User.from_google_oauth(auth) }

    assert_equal "Google account must provide verified email", error.message
  end

  # Friendship helpers

  test "friends returns accepted users in sent direction" do
    # fixture one->two: accepted
    assert_includes users(:one).friends, users(:two)
  end

  test "friends returns accepted users in received direction" do
    assert_includes users(:two).friends, users(:one)
  end

  test "friends excludes pending relationships" do
    # fixture one->three: pending
    assert_not_includes users(:one).friends, users(:three)
  end

  test "friend? returns true for accepted relationship" do
    assert users(:one).friend?(users(:two))
  end

  test "friend? returns true in reverse direction" do
    assert users(:two).friend?(users(:one))
  end

  test "friend? returns false for pending relationship" do
    assert_not users(:one).friend?(users(:three))
  end

  test "friend? returns false when no relationship exists" do
    assert_not users(:two).friend?(users(:three))
  end

  test "friendship_status returns accepted" do
    assert_equal "accepted", users(:one).friendship_status(users(:two))
  end

  test "friendship_status returns accepted in reverse direction" do
    assert_equal "accepted", users(:two).friendship_status(users(:one))
  end

  test "friendship_status returns pending" do
    assert_equal "pending", users(:one).friendship_status(users(:three))
  end

  test "friendship_status returns pending in reverse direction" do
    assert_equal "pending", users(:three).friendship_status(users(:one))
  end

  test "friendship_status returns none when no relationship exists" do
    assert_equal "none", users(:two).friendship_status(users(:three))
  end

  test "friendship_status returns rejected" do
    UserFollowRequest.create!(
      requesting_user: users(:two),
      requested_user: users(:three),
      follow_request_status: :rejected
    )
    assert_equal "rejected", users(:two).friendship_status(users(:three))
  end

  test "friendship_status returns rejected in reverse direction" do
    UserFollowRequest.create!(
      requesting_user: users(:two),
      requested_user: users(:three),
      follow_request_status: :rejected
    )
    assert_equal "rejected", users(:three).friendship_status(users(:two))
  end
end
