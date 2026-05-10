class UserFollowRequest < ApplicationRecord
  belongs_to :requesting_user, class_name: "User"
  belongs_to :requested_user, class_name: "User"

  enum :follow_request_status, { pending: 0, accepted: 1, rejected: 2 }, default: :pending

  validates :requesting_user_id, uniqueness: { scope: :requested_user_id }
  validate :not_following_self

  after_commit :broadcast_pending_count_to_recipient

  private

  def not_following_self
    errors.add(:requested_user_id, "cannot follow yourself") if requesting_user_id == requested_user_id
  end

  def broadcast_pending_count_to_recipient
    recipient = requested_user
    return unless recipient

    count = recipient.received_follow_requests.pending.count
    Turbo::StreamsChannel.broadcast_update_to(
      [ recipient, :pending_requests ],
      target: "pending_request_badge",
      partial: "shared/pending_request_badge",
      locals: { count: count }
    )
  end
end
