class PostsController < ApplicationController
  include AuthorizeOwner

  before_action :authenticate_user!
  before_action :set_post, only: [ :edit, :update, :destroy ]
  before_action :authorize_post_owner!, only: [ :edit, :update, :destroy ]

  def index
    @post = current_user.posts.build
    base = Post.includes(user: :profile).order(created_at: :desc)
    if params[:scope] == "friends"
      friend_user_ids = current_user.friends.ids + [ current_user.id ]
      @pagy, @posts = pagy(base.where(user_id: friend_user_ids))
    else
      @pagy, @posts = pagy(base)
    end
    @likes_by_post_id = current_user.likes.where(post_id: @posts.map(&:id)).index_by(&:post_id)
  end

  def show
    @post = Post.includes(user: :profile).find(params[:id])
    @comment = @post.comments.build
    @pagy_comments, @comments = pagy(@post.comments.includes(user: :profile).order(created_at: :asc))
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
      @pagy, @posts = pagy(Post.includes(user: :profile).order(created_at: :desc))
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
    authorize_owner!(@post, redirect_path: post_path(@post))
  end

  def post_params
    params.require(:post).permit(:content)
  end
end
