# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    handle_auth("Google")
  end

  def line
    handle_auth("LINE")
  end

  def failure
    redirect_to new_user_session_path, alert: "ログインに失敗しました。もう一度お試しください。"
  end

  private

  def handle_auth(provider_label)
    auth = request.env["omniauth.auth"]
    user = User.from_omniauth(auth)

    if user.persisted?
      sign_in_and_redirect user, event: :authentication
      set_flash_message(:notice, :success, kind: provider_label) if is_navigational_format?
    else
      redirect_to new_user_session_path, alert: "#{provider_label}でのログインに失敗しました。"
    end
  end
end
