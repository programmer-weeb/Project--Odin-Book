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
  end

  def reject
  end

  def received
  end

  def sent
  end

  def create
  end

end
