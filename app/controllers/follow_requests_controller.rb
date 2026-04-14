class FollowRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_follow_request, only: [:destroy, :accept, :reject]
  before_action :set_requested_user, only: :create

  def index
    @received_follow_requests = current_user.received_follow_requests.includes(:requesting_user)
    @sent_follow_requests = current_user.sent_follow_requests.includes(:requested_user)
  end

  def destroy
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
