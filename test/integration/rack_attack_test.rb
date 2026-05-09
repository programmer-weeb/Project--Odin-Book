require "test_helper"

class RackAttackTest < ActionDispatch::IntegrationTest
  setup do
    Rack::Attack.enabled = true
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
  end

  teardown do
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new
    Rack::Attack.enabled = false
  end

  test "throttles sign-in after 5 attempts from same IP" do
    5.times do
      post user_session_path, params: { user: { email: "x@example.com", password: "bad" } }
      assert_not_equal 429, response.status
    end

    post user_session_path, params: { user: { email: "x@example.com", password: "bad" } }
    assert_response 429
  end
end
