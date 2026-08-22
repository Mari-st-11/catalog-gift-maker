require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(name: "贈り主", email: "notif-owner@example.com", password: "password123")
    @gift_list = @user.gift_lists.create!(recipient_name: "友人")
    @gift_item = @gift_list.gift_items.create!(user: @user, name: "マグカップ")
    @notification = Notification.create!(user: @user, gift_item: @gift_item)
  end

  test "未ログインではアクセスできない" do
    get notifications_path
    assert_redirected_to new_user_session_path
  end

  test "自分の通知一覧が見られ、閲覧すると既読になる" do
    sign_in @user
    assert_not @notification.reload.is_read

    get notifications_path
    assert_response :success
    assert_match "マグカップ", response.body

    assert @notification.reload.is_read
  end

  test "他人の通知は見えない" do
    other_user = User.create!(name: "他人", email: "notif-other@example.com", password: "password123")
    sign_in other_user

    get notifications_path
    assert_response :success
    assert_no_match "マグカップ", response.body
  end
end
