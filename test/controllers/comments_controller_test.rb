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
end
