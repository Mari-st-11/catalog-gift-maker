# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  # メール/パスワードでの新規登録は停止し、Google/LINEログインに一本化する。
  # 既存のパスワードユーザーのログイン・アカウント編集には影響しない。
  before_action :disable_new_registration, only: %i[ new create ]
  before_action :configure_sign_up_params, only: [ :create ]
  before_action :configure_account_update_params, only: [ :update ]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  protected

  def disable_new_registration
    redirect_to new_user_session_path, alert: "新規登録はGoogle/LINEログインをご利用ください"
  end

  # 新規登録にnameカラムを追加
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name ])
  end

  # プロフィール編集(名前変更)にnameカラムを追加
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name ])
  end

  # OmniAuthでログインしたユーザーはパスワードを知らない(ランダム生成のため)。
  # current_passwordを要求すると名前すら変更できなくなるので、確認なしで更新する。
  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    gift_lists_path
  end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  # プロフィール更新後の遷移先
  def after_update_path_for(resource)
    gift_lists_path
  end
end
