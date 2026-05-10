require "test_helper"

class SearchControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "unauthenticated redirects to sign in" do
    get search_url
    assert_redirected_to new_user_session_url
  end

  test "empty query renders blank results" do
    sign_in @user
    get search_url
    assert_response :success
    assert_select "h1", "Find people and posts."
  end

  test "query matches user by display_name" do
    sign_in @user
    get search_url, params: { q: users(:two).profile.display_name }
    assert_response :success
    assert_match users(:two).profile.display_name, response.body
  end

  test "query matches post by content" do
    sign_in @user
    get search_url, params: { q: posts(:one).content }
    assert_response :success
    assert_match posts(:one).content, response.body
  end

  test "query with no matches renders empty sections" do
    sign_in @user
    get search_url, params: { q: "xyzzy_no_match_ever" }
    assert_response :success
    assert_match "No people matched", response.body
    assert_match "No posts matched", response.body
  end

  test "does not return current user in results" do
    sign_in @user
    get search_url, params: { q: @user.profile.display_name }
    assert_response :success
    assert_match "No people matched", response.body
  end

  test "does not match against full email domain" do
    sign_in @user
    get search_url, params: { q: "example.com" }
    assert_response :success
    assert_match "No people matched", response.body
  end
end
