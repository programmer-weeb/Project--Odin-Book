class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_post, only: :create
  before_action :set_comment, only: :destroy

  def create
    @comment = @post.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      redirect_to post_path(@post), notice: "Comment created."
    else
      redirect_to post_path(@post), alert: @comment.errors.full_messages.to_sentence
    end
  end

  def destroy
    post = @comment.post

    unless @comment.user == current_user || post.user == current_user
      redirect_to post_path(post), alert: "Not authorized."
      return
    end

    @comment.destroy
    redirect_to post_path(post), notice: "Comment deleted."
  end

end
