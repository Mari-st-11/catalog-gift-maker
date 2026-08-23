require "test_helper"

class SharedGiftListFlowTest < ActionDispatch::IntegrationTest
  def setup
    @owner = User.create!(name: "贈り主", email: "owner@example.com", password: "password123")
    @gift_list = @owner.gift_lists.create!(recipient_name: "友人", status: :shared)
    @item_a = @owner.gift_items.create!(gift_list: @gift_list, name: "商品A")
    @item_b = @owner.gift_items.create!(gift_list: @gift_list, name: "商品B")
  end

  test "選択は1回だけ許可され、2回目の選び直しは拒否される" do
    post choose_shared_gift_list_path(@gift_list.public_token), params: { gift_item_id: @item_a.id }
    assert_redirected_to shared_gift_list_path(@gift_list.public_token)
    assert @item_a.reload.confirmed?, "選択と同時に確定(通知)まで完了するはず"
    assert @gift_list.reload.selected?

    post choose_shared_gift_list_path(@gift_list.public_token), params: { gift_item_id: @item_b.id }
    follow_redirect!
    assert_match "すでに他のギフトが選択されています", response.body
    assert @item_a.reload.confirmed?, "最初に選ばれた商品の状態は変わらないはず"
    assert_not @item_b.reload.confirmed?, "2回目の選択は反映されないはず"
  end

  test "cancelは未ログインだと拒否される" do
    @item_a.update!(status: :confirmed)

    post cancel_shared_gift_list_path(@gift_list.public_token)

    assert_redirected_to shared_gift_list_path(@gift_list.public_token)
    assert @item_a.reload.confirmed?, "未ログインではキャンセルできないはず"
  end

  test "cancelは所有者本人なら成功し、選び直せる状態に戻す" do
    @item_a.update!(status: :confirmed)
    @gift_list.update!(status: :selected)
    sign_in @owner

    post cancel_shared_gift_list_path(@gift_list.public_token)

    assert_redirected_to gift_list_path(@gift_list)
    assert @item_a.reload.unselected?
    assert @gift_list.reload.shared?
  end

  test "cancelは所有者以外のログインユーザーだと拒否される" do
    @item_a.update!(status: :confirmed)
    other_user = User.create!(name: "他人", email: "other@example.com", password: "password123")
    sign_in other_user

    post cancel_shared_gift_list_path(@gift_list.public_token)

    assert_redirected_to shared_gift_list_path(@gift_list.public_token)
    assert @item_a.reload.confirmed?
  end

  test "リンクを再発行すると、古いリンクでは案内画面が表示される(生のエラーにならない)" do
    old_token = @gift_list.public_token
    @gift_list.regenerate_public_token!

    get shared_gift_list_path(old_token)

    assert_response :not_found
    assert_match "このリンクは無効です", response.body
  end
end
