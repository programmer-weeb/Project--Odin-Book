class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authorize_post_owner!, only: [:edit, :update, :destroy]

  def index
    @post = current_user.posts.build
    @posts = Post.includes(:user, :comments, :likes).order(created_at: :desc)
  end

  def show
    @comment = @post.comments.build
    @comments = @post.comments.includes(:user).order(created_at: :asc)
  end

  def new
    @post = current_user.posts.build
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

end
