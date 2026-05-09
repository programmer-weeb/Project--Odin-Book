module AuthorizeOwner
  extend ActiveSupport::Concern

  private

  def authorize_owner!(resource, redirect_path:, message: "Not authorized.")
    return if resource.user == current_user
    redirect_to redirect_path, alert: message
  end
end
