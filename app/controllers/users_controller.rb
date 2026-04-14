class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :friends]

  def index
    @users = User.includes(:profile).order(:email)
  end

  def show
    @profile = @user.profile
    @posts = @user.posts.includes(:comments, :likes).order(created_at: :desc)
    @friendship_status = current_user.friendship_status(@user)
  end

  def friends
    @friends = @user.friends.includes(:profile).order(:email)
  end

  private

  def set_user
    @user = User.includes(:profile).find(params[:id])
  end

end
