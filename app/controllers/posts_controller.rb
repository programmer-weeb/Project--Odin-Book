class PostsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: [:show, :edit, :update, :destroy]
  before_action :authorize_post_owner!, only: [:edit, :update, :destroy]

  def index
    @post = current_user.posts.build
    @posts = Post.includes(:user, :comments, :likes).order(created_at: :desc)
    @likes_by_post_id = current_user.likes.where(post_id: @posts.map(&:id)).index_by(&:post_id)
  end

  def show
    @comment = @post.comments.build
    @comments = @post.comments.includes(:user).order(created_at: :asc)
    @likes_by_post_id = current_user.likes.where(post_id: @post.id).index_by(&:post_id)
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)

    if @post.save
      redirect_to post_path(@post), notice: "Post created."
    else
      @posts = Post.includes(:user, :comments, :likes).order(created_at: :desc)
      @likes_by_post_id = current_user.likes.where(post_id: @posts.map(&:id)).index_by(&:post_id)
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to post_path(@post), notice: "Post updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path, notice: "Post deleted."
  end

  private

  def set_post
    @post = Post.find(params[:id])
  end

  def authorize_post_owner!
    return if @post.user == current_user

    redirect_to post_path(@post), alert: "Not authorized."
  end

  def post_params
    params.require(:post).permit(:content)
  end

end
