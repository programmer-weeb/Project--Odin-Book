require "test_helper"

class FollowRequestBadgeTest < ActionDispatch::IntegrationTest
  test "shows pending follow request count in navbar" do
    sign_in users(:three)
    get root_url
    assert_match %r{<span id="pending_request_badge">\s*<span[^>]*>\d+</span>}m, response.body
  end

  test "does not show badge when no pending requests" do
    sign_in users(:one)
    get root_url
    assert_no_match %r{<span id="pending_request_badge">\s*<span[^>]*>\d+</span>}m, response.body
  end
end
