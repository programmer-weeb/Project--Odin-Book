class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :friends]

  def index
    @users = User.includes(:profile).order(:email)
    @friend_ids = current_user.friends.pluck(:id)
    @sent_request_user_ids = current_user.sent_follow_requests.pending.pluck(:requested_user_id)
    @received_request_user_ids = current_user.received_follow_requests.pending.pluck(:requesting_user_id)
  end

  def show
    @profile = @user.profile
    @posts = @user.posts.includes(:comments, :likes).order(created_at: :desc)
    @likes_by_post_id = current_user.likes.where(post_id: @posts.map(&:id)).index_by(&:post_id)
    @friendship_status = current_user.friendship_status(@user)
    @pending_sent_request = current_user.sent_follow_requests.pending.find_by(requested_user: @user)
    @pending_received_request = current_user.received_follow_requests.pending.find_by(requesting_user: @user)
  end

  def friends
    @friends = @user.friends.includes(:profile).order(:email)
  end

  private

  def set_user
    @user = User.includes(:profile).find(params[:id])
  end

end
