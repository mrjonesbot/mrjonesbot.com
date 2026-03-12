# config/initializers/rack_attack.rb
class Rack::Attack
  # Throttle all chat requests by IP (10 req/minute)
  throttle('chat/ip', limit: 10, period: 1.minute) do |req|
    if req.path.start_with?('/chats') && req.post?
      req.ip
    end
  end

  # Throttle chat requests by IP (50 req/hour) for longer-term protection
  throttle('chat/ip/hour', limit: 50, period: 1.hour) do |req|
    if req.path.start_with?('/chats') && req.post?
      req.ip
    end
  end

  # Throttle fit check requests by IP (5 req/5 min)
  throttle('fit_check/ip', limit: 5, period: 5.minutes) do |req|
    if req.path == '/fit_check' && req.post?
      req.ip
    end
  end

  # Block IPs that make too many requests across the entire site
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |env|
    retry_after = (env['rack.attack.match_data'] || {})[:period]
    [
      429,
      {
        'Content-Type' => 'text/html',
        'Retry-After' => retry_after.to_s
      },
      ["<html><body><h1>Rate Limit Exceeded</h1><p>Too many requests. Please try again later.</p></body></html>"]
    ]
  end
end
