require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = posts(:two)
    @comment = comments(:two)
  end

  test "should create comment" do
    sign_in @user

    assert_difference("Comment.count", 1) do
      post post_comments_url(@post), params: { comment: { content: "New comment" } }
    end

    assert_redirected_to post_url(@post)
  end

  test "should destroy own comment" do
    sign_in @user

    assert_difference("Comment.count", -1) do
      delete comment_url(@comment)
    end

    assert_redirected_to post_url(@comment.post)
  end

  test "non-owner non-post-owner cannot destroy comment" do
    # comments(:one): owned by users(:two) on posts(:one) owned by users(:one)
    # users(:three) is neither the comment owner nor the post owner
    sign_in users(:three)

    assert_no_difference("Comment.count") do
      delete comment_url(comments(:one))
    end

    assert_redirected_to post_url(comments(:one).post)
    assert_equal "Not authorized.", flash[:alert]
  end

  test "should create comment via turbo_stream" do
    sign_in @user

    assert_difference("Comment.count", 1) do
      post post_comments_url(@post),
        params: { comment: { content: "Turbo comment" } },
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
    assert_match "text/vnd.turbo-stream.html", response.content_type
  end

  test "should destroy comment via turbo_stream" do
    sign_in @user

    assert_difference("Comment.count", -1) do
      delete comment_url(@comment),
        headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
    assert_match "text/vnd.turbo-stream.html", response.content_type
  end
end
