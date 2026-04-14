class FollowRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_follow_request, only: [:destroy, :accept, :reject]
  before_action :set_requested_user, only: :create

  def index
    @received_follow_requests = current_user.received_follow_requests.includes(:requesting_user)
    @sent_follow_requests = current_user.sent_follow_requests.includes(:requested_user)
  end

  def destroy
    unless follow_request_participant?(@follow_request)
      redirect_to follow_requests_path, alert: "Not authorized."
      return
    end

    @follow_request.destroy
    redirect_to follow_requests_path, notice: "Follow request removed."
  end

  def accept
    unless @follow_request.requested_user == current_user
      redirect_to follow_requests_path, alert: "Not authorized."
      return
    end

    if @follow_request.update(follow_request_status: :accepted)
      redirect_to received_follow_requests_path, notice: "Follow request accepted."
    else
      redirect_to received_follow_requests_path, alert: @follow_request.errors.full_messages.to_sentence
    end
  end

  def reject
    unless @follow_request.requested_user == current_user
      redirect_to follow_requests_path, alert: "Not authorized."
      return
    end

    if @follow_request.update(follow_request_status: :rejected)
      redirect_to received_follow_requests_path, notice: "Follow request rejected."
    else
      redirect_to received_follow_requests_path, alert: @follow_request.errors.full_messages.to_sentence
    end
  end

  def received
  end

  def sent
  end

  def create
  end

end
