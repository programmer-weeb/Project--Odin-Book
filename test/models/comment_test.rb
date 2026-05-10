require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "invalid without content" do
    comment = Comment.new(user: users(:one), post: posts(:one))
    assert_not comment.valid?
    assert_includes comment.errors[:content], "can't be blank"
  end

  test "invalid when content exceeds 500 characters" do
    comment = Comment.new(user: users(:one), post: posts(:one), content: "a" * 501)
    assert_not comment.valid?
  end

  test "belongs to user" do
    assert_equal users(:two), comments(:one).user
  end

  test "counter cache increments post comments_count" do
    post = posts(:three)
    before = post.comments_count
    Comment.create!(user: users(:one), post: post, content: "Counter test")
    assert_equal before + 1, post.reload.comments_count
  end

  test "broadcasts prepend on create" do
    post = posts(:three)
    assert_turbo_stream_broadcasts [ post, :comments ], count: 1 do
      Comment.create!(user: users(:one), post: post, content: "Broadcast test")
    end
  end

  test "broadcasts remove on destroy" do
    comment = comments(:one)
    post = comment.post
    assert_turbo_stream_broadcasts [ post, :comments ], count: 1 do
      comment.destroy!
    end
  end
end
