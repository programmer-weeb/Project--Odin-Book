class LikesController < ApplicationController
  include AuthorizeOwner

  before_action :authenticate_user!
  before_action :set_post, only: :create
  before_action :set_like, only: :destroy

  def create
    @like = @post.likes.build(user: current_user)

    if @like.save
      redirect_to post_path(@post), notice: "Post liked."
    else
      redirect_to post_path(@post), alert: @like.errors.full_messages.to_sentence
    end
  end

  def destroy
    authorize_owner!(@like, redirect_path: post_path(@like.post))
    return if performed?

    post = @like.post
    @like.destroy
    redirect_to post_path(post), notice: "Like removed."
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def set_like
    @like = Like.find(params[:id])
  end

end
