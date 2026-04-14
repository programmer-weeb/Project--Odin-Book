class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_google_oauth(request.env["omniauth.auth"])

    set_flash_message(:notice, :success, kind: "Google") if is_navigational_format?
    sign_in_and_redirect @user, event: :authentication
  rescue ArgumentError => e
    redirect_to new_user_session_path, alert: e.message
  rescue ActiveRecord::RecordInvalid => e
    redirect_to new_user_registration_path, alert: e.record.errors.full_messages.to_sentence
  end

  def failure
    redirect_to new_user_session_path, alert: "Google sign in failed. Please try again."
  end
end
