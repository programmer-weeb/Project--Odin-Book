require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = posts(:one)
    @other_post = posts(:two)
  end

  test "redirects index when not signed in" do
    get posts_url
    assert_redirected_to new_user_session_url
  end

  test "should get index when signed in" do
    sign_in @user

    get posts_url
    assert_response :success
  end

  test "should get show" do
    sign_in @user

    get post_url(@post)
    assert_response :success
  end

  test "should get new" do
    sign_in @user

    get new_post_url
    assert_response :success
  end

  test "should create post" do
    sign_in @user

    assert_difference("Post.count", 1) do
      post posts_url, params: { post: { content: "New post content" } }
    end

    assert_redirected_to post_url(Post.order(:id).last)
  end

  test "should get edit" do
    sign_in @user

    get edit_post_url(@post)
    assert_response :success
  end

  test "should update post" do
    sign_in @user

    patch post_url(@post), params: { post: { content: "Updated content" } }

    assert_redirected_to post_url(@post)
    assert_equal "Updated content", @post.reload.content
  end

  test "should destroy post" do
    sign_in @user

    assert_difference("Post.count", -1) do
      delete post_url(@post)
    end

    assert_redirected_to posts_url
  end

  test "non-owner cannot edit another user's post" do
    sign_in @user

    get edit_post_url(@other_post)

    assert_redirected_to post_url(@other_post)
    assert_equal "Not authorized.", flash[:alert]
  end

  test "non-owner cannot update another user's post" do
    sign_in @user

    patch post_url(@other_post), params: { post: { content: "Hijacked" } }

    assert_redirected_to post_url(@other_post)
    assert_equal "Not authorized.", flash[:alert]
    assert_not_equal "Hijacked", @other_post.reload.content
  end

  test "non-owner cannot destroy another user's post" do
    sign_in @user

    assert_no_difference("Post.count") do
      delete post_url(@other_post)
    end

    assert_redirected_to post_url(@other_post)
    assert_equal "Not authorized.", flash[:alert]
  end

  test "index page=2 returns success" do
    sign_in @user

    get posts_url, params: { page: 2 }
    assert_response :success
  end

  test "index page 1 shows pagy navigation when many posts exist" do
    sign_in @user
    21.times { |i| Post.create!(content: "Feed post #{i}", user: @user) }

    get posts_url
    assert_response :success
    assert_match(/class="pagy nav"/, response.body)
  end

  test "scope=friends limits feed to current user and friends posts" do
    sign_in @user
    get posts_url, params: { scope: "friends" }
    assert_response :success
    response_body = response.body
    assert_match posts(:one).content, response_body
    assert_match posts(:two).content, response_body
    assert_no_match posts(:three).content, response_body
  end
end
