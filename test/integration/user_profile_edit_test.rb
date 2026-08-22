require "test_helper"

class UserProfileEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(name: "Google太郎", email: "oauth-user@example.com", password: Devise.friendly_token[0, 20])
  end

  test "現在のパスワードを知らなくても表示名を変更できる(OmniAuthユーザー向け)" do
    sign_in @user

    patch user_registration_path, params: { user: { name: "新しい名前" } }

    assert_redirected_to gift_lists_path
    assert_equal "新しい名前", @user.reload.name
  end

  test "未ログインでは編集画面にアクセスできない" do
    get edit_user_registration_path
    assert_redirected_to new_user_session_path
  end
end
