require "test_helper"

class LikeTest < ActiveSupport::TestCase
  test "uniqueness scoped to user and post" do
    # likes(:one): user two, post one — already exists
    duplicate = Like.new(user: users(:two), post: posts(:one))
    assert_not duplicate.valid?
    assert_includes duplicate.errors[:user_id], "has already been taken"
  end

  test "different user can like same post" do
    like = Like.new(user: users(:three), post: posts(:one))
    assert like.valid?
  end

  test "same user can like different post" do
    like = Like.new(user: users(:two), post: posts(:three))
    assert like.valid?
  end

  test "broadcasts like_count update on create" do
    post = posts(:one)
    assert_turbo_stream_broadcasts [ post, :likes ], count: 1 do
      post.likes.create!(user: users(:three))
    end
  end

  test "broadcasts like_count update on destroy" do
    like = likes(:one)
    post = like.post
    assert_turbo_stream_broadcasts [ post, :likes ], count: 1 do
      like.destroy!
    end
  end
end
