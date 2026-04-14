class AddCounterCachesToPosts < ActiveRecord::Migration[8.0]
  def change
    add_column :posts, :likes_count, :integer, default: 0, null: false
    add_column :posts, :comments_count, :integer, default: 0, null: false

    # Reset counters for existing data (if any)
    up_only do
      Post.reset_column_information
      Post.find_each do |post|
        Post.reset_counters(post.id, :likes, :comments)
      end
    end
  end
end
