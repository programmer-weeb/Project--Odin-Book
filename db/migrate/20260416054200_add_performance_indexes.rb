class AddPerformanceIndexes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def change
    # Posts: Speed up user feeds and timeline ordering
    add_index :posts, [ :user_id, :created_at ], algorithm: :concurrently, if_not_exists: true

    # Comments: Faster loading of comment threads
    add_index :comments, [ :post_id, :created_at ], algorithm: :concurrently, if_not_exists: true

    # Likes: Chronological like lookups and counts per post
    add_index :likes, [ :post_id, :created_at ], algorithm: :concurrently, if_not_exists: true

    # UserFollowRequests: Optimize inbox/outbox filtering by status
    add_index :user_follow_requests, [ :requested_user_id, :follow_request_status ],
              name: "idx_follow_req_on_requested_and_status",
              algorithm: :concurrently,
              if_not_exists: true
    add_index :user_follow_requests, [ :requesting_user_id, :follow_request_status ],
              name: "idx_follow_req_on_requesting_and_status",
              algorithm: :concurrently,
              if_not_exists: true
  end
end
