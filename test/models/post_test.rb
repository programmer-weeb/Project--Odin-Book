require "test_helper"

class PostTest < ActiveSupport::TestCase
  test "invalid without content" do
    post = Post.new(user: users(:one))
    assert_not post.valid?
    assert_includes post.errors[:content], "can't be blank"
  end

  test "invalid when content exceeds 1000 characters" do
    post = Post.new(user: users(:one), content: "a" * 1001)
    assert_not post.valid?
  end

  test "belongs to user" do
    assert_equal users(:one), posts(:one).user
  end

  test "valid with content and user" do
    post = Post.new(user: users(:one), content: "Hello world")
    assert post.valid?
  end
end
