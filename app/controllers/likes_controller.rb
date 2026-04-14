class LikesController < ApplicationController
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
    unless @like.user == current_user
      redirect_to post_path(@like.post), alert: "Not authorized."
      return
    end

    post = @like.post
    @like.destroy
    redirect_to post_path(post), notice: "Like removed."
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

end
