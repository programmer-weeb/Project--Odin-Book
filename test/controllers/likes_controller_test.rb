require "test_helper"

class LikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @post = posts(:three)
    @like = likes(:two)
  end

  test "should create like" do
    sign_in @user

    assert_difference("Like.count", 1) do
      post post_likes_url(@post)
    end

    assert_redirected_to post_url(@post)
  end

  test "should destroy own like" do
    sign_in @user

    assert_difference("Like.count", -1) do
      delete like_url(@like)
    end

    assert_redirected_to post_url(@like.post)
  end
end
