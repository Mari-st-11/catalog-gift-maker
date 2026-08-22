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

  test "メール/パスワードでの新規登録画面は表示されず、ログイン画面へ誘導される" do
    get new_user_registration_path
    assert_redirected_to new_user_session_path
  end

  test "メール/パスワードでの新規登録は作成されない" do
    assert_no_difference -> { User.count } do
      post user_registration_path, params: { user: { name: "不正登録", email: "blocked@example.com", password: "password123", password_confirmation: "password123" } }
    end
    assert_redirected_to new_user_session_path
  end

  test "既存のパスワードユーザーはブロックの影響を受けずログインできる" do
    @user.update!(password: "password123")

    post user_session_path, params: { user: { email: @user.email, password: "password123" } }

    assert_redirected_to gift_lists_path
  end
end
