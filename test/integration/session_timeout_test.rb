require "test_helper"

class SessionTimeoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(name: "テスト", email: "timeout-user@example.com", password: Devise.friendly_token[0, 20])
  end

  test "一定期間操作がなければ自動的にログアウトされる" do
    sign_in @user

    get gift_lists_path
    assert_response :success

    travel 2.weeks + 1.hour do
      get edit_user_registration_path
      # Deviseはタイムアウト時、まず元のページへ再アクセスさせてから
      # 改めて未ログイン判定でログイン画面へリダイレクトする(2段階になる)
      follow_redirect!
      assert_redirected_to new_user_session_path
    end
  end

  test "タイムアウト期間内であればログイン状態が維持される" do
    sign_in @user

    travel 1.week do
      get edit_user_registration_path
      assert_response :success
    end
  end
end
