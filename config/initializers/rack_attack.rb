Rack::Attack.throttle("sign_in/ip", limit: 5, period: 20) do |req|
  req.ip if req.post? && req.path == "/users/sign_in"
end

Rack::Attack.throttle("registration/ip", limit: 3, period: 60) do |req|
  req.ip if req.post? && req.path == "/users"
end

Rack::Attack.throttle("posts/ip", limit: 10, period: 60) do |req|
  req.ip if req.post? && req.path == "/posts"
end

Rack::Attack.throttle("likes_comments/ip", limit: 30, period: 60) do |req|
  req.ip if req.post? && req.path.match?(%r{/posts/\d+/(likes|comments)})
end

Rack::Attack.throttle("follow_requests/ip", limit: 10, period: 60) do |req|
  req.ip if req.post? && req.path.match?(%r{/users/\d+/follow_requests})
end

Rack::Attack.throttled_responder = lambda do |_env|
  [429, { "content-type" => "text/plain" }, ["Too many requests. Please try again later."]]
end
