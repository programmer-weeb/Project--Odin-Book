Rack::Attack.safelist("allow from localhost") do |req|
  req.ip == "127.0.0.1" || req.ip == "::1"
end

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
  req.ip if req.post? && req.path.match?(%r{\A/posts/\d+/(likes|comments)\z})
end

Rack::Attack.throttle("follow_requests/ip", limit: 10, period: 60) do |req|
  req.ip if req.post? && req.path.match?(%r{\A/users/\d+/follow_requests\z})
end

Rack::Attack.throttle("follow_request_actions/ip", limit: 20, period: 60) do |req|
  req.ip if req.patch? && req.path.match?(%r{\A/follow_requests/\d+/(accept|reject)\z})
end

Rack::Attack.throttled_responder = lambda do |_env|
  [ 429, { "content-type" => "text/plain" }, [ "Too many requests. Please try again later." ] ]
end
