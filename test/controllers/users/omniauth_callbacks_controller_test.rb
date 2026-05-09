require "test_helper"

class Users::OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    Rails.application.env_config["devise.mapping"] = Devise.mappings[:user]
  end

  teardown do
    OmniAuth.config.mock_auth[:google_oauth2] = nil
    OmniAuth.config.test_mode = false
    Rails.application.env_config["omniauth.auth"] = nil
  end

  def set_auth(uid: "uid-123", email: "new@example.com", name: "New User", verified: true)
    auth = OmniAuth::AuthHash.new(
      provider: "google_oauth2",
      uid: uid,
      info: { email: email, name: name, email_verified: verified },
      extra: { raw_info: { email_verified: verified } }
    )
    OmniAuth.config.mock_auth[:google_oauth2] = auth
    Rails.application.env_config["omniauth.auth"] = auth
  end

  test "creates new user on successful Google sign-in with verified email" do
    set_auth(email: "brandnew@example.com", uid: "uid-brandnew")

    assert_difference("User.count", 1) do
      get user_google_oauth2_omniauth_callback_path
    end

    assert_response :redirect
    user = User.find_by(email: "brandnew@example.com")
    assert_not_nil user
    assert_equal "google_oauth2", user.provider
    assert_equal "uid-brandnew", user.uid
  end

  test "finds existing user by uid and provider without creating new record" do
    existing = users(:one)
    existing.update!(provider: "google_oauth2", uid: "uid-existing-one")
    set_auth(email: existing.email, uid: "uid-existing-one")

    assert_no_difference("User.count") do
      get user_google_oauth2_omniauth_callback_path
    end

    assert_response :redirect
  end

  test "links provider and uid to existing user found by email" do
    existing = users(:two)
    set_auth(email: existing.email, uid: "uid-link-two")

    assert_no_difference("User.count") do
      get user_google_oauth2_omniauth_callback_path
    end

    existing.reload
    assert_equal "google_oauth2", existing.provider
    assert_equal "uid-link-two", existing.uid
  end

  test "unverified email redirects to sign-in with alert" do
    set_auth(email: "unverified@example.com", verified: false)

    get user_google_oauth2_omniauth_callback_path

    assert_redirected_to new_user_session_path
    assert_equal "Google account must provide verified email", flash[:alert]
  end

  test "RecordInvalid redirects to registration with alert" do
    set_auth

    invalid_user = User.new
    invalid_user.errors.add(:email, "has already been taken")
    original = User.method(:from_google_oauth)

    User.define_singleton_method(:from_google_oauth) do |_auth|
      raise ActiveRecord::RecordInvalid.new(invalid_user)
    end

    begin
      get user_google_oauth2_omniauth_callback_path
    ensure
      User.define_singleton_method(:from_google_oauth, original)
    end

    assert_redirected_to new_user_registration_path
    assert_match "Email has already been taken", flash[:alert]
  end

  test "failure action redirects to sign-in with alert" do
    OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials

    post "/users/auth/google_oauth2"
    follow_redirect!

    assert_redirected_to new_user_session_path
    assert_equal "Google sign in failed. Please try again.", flash[:alert]
  end
end
