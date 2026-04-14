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
end
