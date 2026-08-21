require "test_helper"

class GiftListTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(name: "贈り主", email: "sender@example.com", password: "password123")
    @gift_list = @user.gift_lists.create!(recipient_name: "お母さん")
  end

  test "uuid(内部識別子)とpublic_token(公開URL用)が別々に発行される" do
    assert @gift_list.uuid.present?
    assert @gift_list.public_token.present?
    assert_not_equal @gift_list.uuid, @gift_list.public_token
  end

  test "try_mark_selected!はshared状態から1回だけ成功する(排他制御)" do
    @gift_list.update!(status: :shared)

    assert @gift_list.try_mark_selected!
    assert @gift_list.reload.selected?
    assert_not @gift_list.try_mark_selected!, "2回目の選択は拒否されるべき"
  end

  test "try_mark_selected!はdraft状態からも成功する(公開フローが未整備な既存データ互換)" do
    @gift_list.update!(status: :draft)
    assert @gift_list.try_mark_selected!
  end

  test "try_mark_selected!はselected/completedの状態では失敗する" do
    @gift_list.update!(status: :completed)
    assert_not @gift_list.try_mark_selected!
  end

  test "regenerate_public_token!はuuidを変えずpublic_tokenだけ再発行する" do
    old_token = @gift_list.public_token
    old_uuid = @gift_list.uuid

    @gift_list.regenerate_public_token!

    assert_not_equal old_token, @gift_list.public_token
    assert_equal old_uuid, @gift_list.uuid
  end
end
