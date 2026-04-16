class RemoveRedundantIndexes < ActiveRecord::Migration[8.0]
  disable_ddl_transaction!

  def up
    remove_index :comments, name: :index_comments_on_post_id, algorithm: :concurrently
    remove_index :likes, name: :index_likes_on_post_id, algorithm: :concurrently
    remove_index :likes, name: :index_likes_on_user_id, algorithm: :concurrently
    remove_index :posts, name: :index_posts_on_user_id, algorithm: :concurrently
    remove_index :user_follow_requests, name: :index_user_follow_requests_on_requested_user_id, algorithm: :concurrently
    remove_index :user_follow_requests, name: :index_user_follow_requests_on_requesting_user_id, algorithm: :concurrently
  end

  def down
    add_index :comments, :post_id, name: :index_comments_on_post_id, algorithm: :concurrently
    add_index :likes, :post_id, name: :index_likes_on_post_id, algorithm: :concurrently
    add_index :likes, :user_id, name: :index_likes_on_user_id, algorithm: :concurrently
    add_index :posts, :user_id, name: :index_posts_on_user_id, algorithm: :concurrently
    add_index :user_follow_requests, :requested_user_id, name: :index_user_follow_requests_on_requested_user_id, algorithm: :concurrently
    add_index :user_follow_requests, :requesting_user_id, name: :index_user_follow_requests_on_requesting_user_id, algorithm: :concurrently
  end
end
