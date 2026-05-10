class Like < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  validates :user_id, uniqueness: { scope: :post_id }

  after_create_commit -> { broadcast_like_count }
  after_destroy_commit -> { broadcast_like_count }

  private

  def broadcast_like_count
    count = Post.where(id: post_id).pick(:likes_count)
    return unless count

    Turbo::StreamsChannel.broadcast_update_to(
      [ post, :likes ],
      target: ActionView::RecordIdentifier.dom_id(post, :like_count),
      content: count.to_s
    )
  end
end
