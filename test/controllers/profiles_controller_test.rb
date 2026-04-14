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
end
