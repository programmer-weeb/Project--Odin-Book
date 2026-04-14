srand(12_345)

puts "Clearing old data..."
Comment.delete_all
Like.delete_all
Post.delete_all
UserFollowRequest.delete_all
Profile.delete_all
User.delete_all

PASSWORD = "password123".freeze

USER_SEEDS = [
  { email: "alex@example.com", display_name: "Alex Mercer", bio: "Reads changelogs for fun and never skips code review." },
  { email: "maya@example.com", display_name: "Maya Stone", bio: "Backend-heavy builder. Coffee, SQL, and quiet focus." },
  { email: "omar@example.com", display_name: "Omar Khaled", bio: "Ships features fast, then comes back for polish." },
  { email: "lina@example.com", display_name: "Lina Park", bio: "Likes clean UI, simple forms, and sharp edge cases." },
  { email: "sam@example.com", display_name: "Sam Rivers", bio: "Keeps notes on bugs, fixes, and ideas worth revisiting." },
  { email: "nora@example.com", display_name: "Nora Vale", bio: "Rails developer. Strong opinions about naming things." },
  { email: "yousef@example.com", display_name: "Yousef Amin", bio: "Builds side projects at midnight and tests them at dawn." },
  { email: "emma@example.com", display_name: "Emma Hart", bio: "Writes tiny helpers that save whole afternoons." },
  { email: "daniel@example.com", display_name: "Daniel West", bio: "Trying to keep every repo easier to understand than yesterday." },
  { email: "zoe@example.com", display_name: "Zoe Lane", bio: "Frontend leaning. Still ends up fixing database bugs." },
  { email: "ibrahim@example.com", display_name: "Ibrahim Noor", bio: "Makes plans, trims plans, ships trimmed plans." },
  { email: "clara@example.com", display_name: "Clara Finch", bio: "Debugger first. Optimist second." },
  { email: "hassan@example.com", display_name: "Hassan Adel", bio: "Enjoys refactors with small diffs and clear wins." },
  { email: "ruby@example.com", display_name: "Ruby Cole", bio: "Keeps product copy short and commit messages shorter." },
  { email: "leo@example.com", display_name: "Leo Grant", bio: "Testing habit strong. Trust habit weak." },
  { email: "sara@example.com", display_name: "Sara Nabil", bio: "Enjoys building social apps, dashboards, and tiny automation tools." },
  { email: "mina@example.com", display_name: "Mina Fares", bio: "Finds broken assumptions faster than broken code." },
  { email: "julia@example.com", display_name: "Julia Frost", bio: "Design-minded engineer with suspiciously organized tabs." },
  { email: "karim@example.com", display_name: "Karim Mostafa", bio: "Can explain tricky bugs with one query and one screenshot." },
  { email: "hana@example.com", display_name: "Hana Reed", bio: "Always editing profile bio. Rarely satisfied with final draft." }
].freeze

POST_OPENERS = [
  "Today I cleaned up one small part of a project and somehow the whole app felt easier to read.",
  "Spent half the day chasing a bug that turned out to be one missing assumption.",
  "I like when a feature gets smaller during implementation instead of bigger.",
  "Nothing dramatic, just steady progress and fewer rough edges than yesterday.",
  "Finally got a stubborn test passing for the right reason, not by accident.",
  "Small reminder that naming is still one of the hardest parts of programming.",
  "Built something simple today. Simple took longer than expected.",
  "I keep thinking good defaults are one of the most underrated product decisions.",
  "Some days the best refactor is deleting code no one needed anymore.",
  "Strong case for writing the tiny helper before repeating the same logic five times."
].freeze

POST_FOLLOWUPS = [
  "Now I want to clean up the rest with same energy.",
  "Feels boring in best possible way.",
  "Would do again.",
  "Next step is tighten tests and leave it alone.",
  "Trying not to overbuild from here.",
  "That change removed more confusion than code.",
  "Still a few rough spots, but path is clearer now.",
  "Shipping small beats planning perfect.",
  "Good reminder that clear structure saves time later.",
  "One more pass and it should stay out of my way."
].freeze

COMMENT_SNIPPETS = [
  "Clean result. I like this direction.",
  "This feels much easier to reason about.",
  "Good call keeping scope small.",
  "I ran into same issue last week.",
  "Nice. That follow-up makes sense too.",
  "This is exactly why defaults matter.",
  "Agreed. Less code, less noise.",
  "Solid tradeoff for first pass.",
  "That last line says everything.",
  "Would love to see where you take this next."
].freeze

users = USER_SEEDS.map do |attrs|
  user = User.create!(
    email: attrs[:email],
    password: PASSWORD,
    password_confirmation: PASSWORD
  )

  user.profile.update!(
    display_name: attrs[:display_name],
    bio: attrs[:bio]
  )

  user
end

puts "Created #{users.count} users..."

posts = []

users.each_with_index do |user, index|
  rand(4..7).times do |n|
    content = [
      POST_OPENERS.sample,
      POST_FOLLOWUPS.sample,
      "Post ##{n + 1} from #{user.profile.display_name.split.first}.",
      "Thread seed #{index + 1}-#{n + 1}."
    ].join(" ")

    posts << user.posts.create!(content: content)
  end
end

puts "Created #{posts.count} posts..."

posts.each do |post|
  commenters = users.reject { |user| user == post.user }.sample(rand(2..6))

  commenters.each do |commenter|
    comment_body = [
      COMMENT_SNIPPETS.sample,
      POST_FOLLOWUPS.sample
    ].join(" ")

    post.comments.create!(
      user: commenter,
      content: comment_body
    )
  end
end

puts "Created #{Comment.count} comments..."

posts.each do |post|
  likers = users.reject { |user| user == post.user }.sample(rand(4..12))

  likers.each do |liker|
    post.likes.create!(user: liker)
  end
end

puts "Created #{Like.count} likes..."

accepted_pairs = {}
pending_pairs = {}
rejected_pairs = {}

users.combination(2).to_a.sample(55).each_with_index do |(user_a, user_b), index|
  requester, requested = index.even? ? [user_a, user_b] : [user_b, user_a]
  key = [requester.id, requested.id]

  next if accepted_pairs[key] || pending_pairs[key] || rejected_pairs[key]

  UserFollowRequest.create!(
    requesting_user: requester,
    requested_user: requested,
    follow_request_status: :accepted
  )

  accepted_pairs[key] = true
end

users.combination(2).to_a.sample(18).each_with_index do |(user_a, user_b), index|
  requester, requested = index.even? ? [user_a, user_b] : [user_b, user_a]
  key = [requester.id, requested.id]
  reverse_key = [requested.id, requester.id]

  next if accepted_pairs[key] || accepted_pairs[reverse_key] || pending_pairs[key] || rejected_pairs[key]

  UserFollowRequest.create!(
    requesting_user: requester,
    requested_user: requested,
    follow_request_status: :pending
  )

  pending_pairs[key] = true
end

users.combination(2).to_a.sample(14).each_with_index do |(user_a, user_b), index|
  requester, requested = index.even? ? [user_a, user_b] : [user_b, user_a]
  key = [requester.id, requested.id]
  reverse_key = [requested.id, requester.id]

  next if accepted_pairs[key] || accepted_pairs[reverse_key] || pending_pairs[key] || pending_pairs[reverse_key] || rejected_pairs[key]

  UserFollowRequest.create!(
    requesting_user: requester,
    requested_user: requested,
    follow_request_status: :rejected
  )

  rejected_pairs[key] = true
end

puts "Created #{UserFollowRequest.count} follow requests..."
puts
puts "Seed complete."
puts "Login with any seeded email and password: #{PASSWORD}"
