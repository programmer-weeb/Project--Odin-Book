require "test_helper"

class PostsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = posts(:one)
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
end
