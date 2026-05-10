class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :post, counter_cache: true

  validates :content, presence: true, length: { maximum: 500 }

  after_create_commit -> {
    broadcast_prepend_to [ post, :comments ],
      target: "comments",
      partial: "comments/comment",
      locals: { comment: self, post: post }
  }

  after_destroy_commit -> {
    broadcast_remove_to [ post, :comments ]
  }
end
