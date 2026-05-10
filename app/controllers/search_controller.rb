class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @query = params[:q].to_s.strip
    if @query.present?
      @users = User.joins(:profile)
                   .where("profiles.display_name ILIKE :q OR users.email ILIKE :q", q: "%#{@query}%")
                   .includes(:profile)
                   .limit(20)
      @posts = Post.where("content ILIKE ?", "%#{@query}%")
                   .includes(user: :profile)
                   .order(created_at: :desc)
                   .limit(20)
      @likes_by_post_id = current_user.likes.where(post_id: @posts.map(&:id)).index_by(&:post_id)
      @friend_ids = current_user.friends.ids
      @sent_request_user_ids = current_user.sent_follow_requests.pending.pluck(:requested_user_id)
      @received_request_user_ids = current_user.received_follow_requests.pending.pluck(:requesting_user_id)
    else
      @users = User.none
      @posts = Post.none
      @likes_by_post_id = {}
      @friend_ids = []
      @sent_request_user_ids = []
      @received_request_user_ids = []
    end
  end
end
