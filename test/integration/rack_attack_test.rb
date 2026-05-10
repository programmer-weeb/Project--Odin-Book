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
    # Pin time to mid-window so the counter cannot reset across a 20s boundary.
    travel_to Time.zone.now.beginning_of_minute + 10.seconds do
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
  end

  test "throttles post creation after 10 in 60s" do
    sign_in users(:one)

    travel_to Time.zone.now.beginning_of_minute + 30.seconds do
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
  end

  test "throttles comment creation after 30 in 60s per IP" do
    sign_in users(:one)

    travel_to Time.zone.now.beginning_of_minute + 30.seconds do
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
  end

  test "throttles follow request accept/reject after 20 in 60s" do
    sign_in users(:three)
    request_id = user_follow_requests(:two).id  # one -> three, pending

    travel_to Time.zone.now.beginning_of_minute + 30.seconds do
      20.times do
        patch accept_follow_request_path(request_id),
          headers: { "REMOTE_ADDR" => "1.2.3.4" }
        assert_not_equal 429, response.status
      end

      patch accept_follow_request_path(request_id),
        headers: { "REMOTE_ADDR" => "1.2.3.4" }
      assert_response 429
    end
  end

  test "throttles follow request creation after 10 in 60s" do
    sign_in users(:one)

    # Rack::Attack increments the counter before the controller runs, so
    # even repeated POSTs to a user with an existing request are counted.
    travel_to Time.zone.now.beginning_of_minute + 30.seconds do
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
end
