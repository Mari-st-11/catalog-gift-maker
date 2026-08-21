require "test_helper"

class UserTest < ActiveSupport::TestCase
  def build_auth(provider:, uid:, email:, name: "OmniAuth User")
    OmniAuth::AuthHash.new(
      provider: provider,
      uid: uid,
      info: { email: email, name: name }
    )
  end

  test "初回ログインなら新規ユーザーを作成する" do
    auth = build_auth(provider: "google_oauth2", uid: "12345", email: "newuser@example.com")

    assert_difference -> { User.count }, 1 do
      user = User.from_omniauth(auth)
      assert_equal "google_oauth2", user.provider
      assert_equal "12345", user.uid
      assert_equal "newuser@example.com", user.email
    end
  end

  test "同じメールアドレスの既存ユーザーがいれば、新規作成せず連携する" do
    existing = User.create!(name: "既存ユーザー", email: "existing@example.com", password: "password123")
    auth = build_auth(provider: "google_oauth2", uid: "99999", email: "existing@example.com")

    assert_no_difference -> { User.count } do
      user = User.from_omniauth(auth)
      assert_equal existing.id, user.id
      assert_equal "google_oauth2", user.reload.provider
      assert_equal "99999", user.uid
    end
  end

  test "同じprovider/uidでの再ログインは同じユーザーを返す" do
    auth = build_auth(provider: "line", uid: "abc", email: "lineuser@example.com")
    first = User.from_omniauth(auth)

    assert_no_difference -> { User.count } do
      second = User.from_omniauth(auth)
      assert_equal first.id, second.id
    end
  end
end
