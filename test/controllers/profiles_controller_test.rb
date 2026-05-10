require "test_helper"

class ProfilesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should get edit" do
    sign_in @user

    get edit_profile_url
    assert_response :success
  end

  test "should update profile" do
    sign_in @user

    patch profile_url, params: { profile: { display_name: "Updated Name", bio: "Updated bio" } }

    assert_redirected_to user_url(@user)
    assert_equal "Updated Name", @user.profile.reload.display_name
  end

  test "should attach profile photo" do
    sign_in @user

    patch profile_url, params: {
      profile: {
        photo: Rack::Test::UploadedFile.new(Rails.root.join("public/icon.png"), "image/png")
      }
    }

    assert_redirected_to user_url(@user)
    assert @user.profile.reload.photo.attached?
  end

  test "signed-in user can delete attached photo" do
    sign_in @user

    @user.profile.photo.attach(
      io: File.open(Rails.root.join("public/icon.png")),
      filename: "icon.png",
      content_type: "image/png"
    )
    assert @user.profile.photo.attached?

    delete photo_profile_url

    assert_redirected_to edit_profile_url
    assert_not @user.profile.reload.photo.attached?
  end

  test "unauthenticated user cannot delete photo" do
    delete photo_profile_url
    assert_redirected_to new_user_session_url
  end
end
