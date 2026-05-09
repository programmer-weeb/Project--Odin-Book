require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    @original_store = Rack::Attack.cache.store
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rack::Attack.cache.store = @original_store
  end

  test "throttles sign-in after 5 attempts from same IP" do
    5.times do
      post user_session_path,
        params: { user: { email: "x@example.com", password: "bad" } },
        headers: { "REMOTE_ADDR" => "1.2.3.4" }
      assert_not_equal 429, response.status
    end

    post user_session_path,
      params: { user: { email: "x@example.com", password: "bad" } },
      headers: { "REMOTE_ADDR" => "1.2.3.4" }
    assert_response 429
  end

  test "throttles post creation after 10 in 60s" do
    sign_in users(:one)

    10.times do
      post posts_path,
        params: { post: { content: "test" } },
        headers: { "REMOTE_ADDR" => "1.2.3.4" }
      assert_not_equal 429, response.status
    end

    post posts_path,
      params: { post: { content: "test" } },
      headers: { "REMOTE_ADDR" => "1.2.3.4" }
    assert_response 429
  end

  test "throttles comment creation after 30 in 60s per IP" do
    sign_in users(:one)

    30.times do
      post post_comments_path(posts(:two)),
        params: { comment: { content: "test" } },
        headers: { "REMOTE_ADDR" => "1.2.3.4" }
      assert_not_equal 429, response.status
    end

    post post_comments_path(posts(:two)),
      params: { comment: { content: "test" } },
      headers: { "REMOTE_ADDR" => "1.2.3.4" }
    assert_response 429
  end

  test "throttles follow request creation after 10 in 60s" do
    sign_in users(:one)

    # Rack::Attack increments the counter before the controller runs, so
    # even repeated POSTs to a user with an existing request are counted.
    10.times do
      post user_follow_requests_path(users(:two)),
        headers: { "REMOTE_ADDR" => "1.2.3.4" }
      assert_not_equal 429, response.status
    end

    post user_follow_requests_path(users(:two)),
      headers: { "REMOTE_ADDR" => "1.2.3.4" }
    assert_response 429
  end
end
