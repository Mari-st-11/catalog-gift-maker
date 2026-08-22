require "test_helper"

class GiftItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(name: "贈り主", email: "owner2@example.com", password: "password123")
    @other_user = User.create!(name: "他人", email: "other2@example.com", password: "password123")
    @gift_list = @user.gift_lists.create!(recipient_name: "お母さん")
    @other_gift_list = @other_user.gift_lists.create!(recipient_name: "友人")
  end

  test "未ログインではnew/createにアクセスできない" do
    get new_gift_list_gift_item_path(@gift_list)
    assert_redirected_to new_user_session_path

    assert_no_difference -> { GiftItem.count } do
      post gift_list_gift_items_path(@gift_list), params: { gift_item: { name: "商品" } }
    end
  end

  test "所有者は自分のギフトリストにギフトを手動登録できる" do
    sign_in @user

    assert_difference -> { @gift_list.gift_items.count }, 1 do
      post gift_list_gift_items_path(@gift_list), params: { gift_item: { name: "マグカップ", description: "説明" } }
    end

    gift_item = @gift_list.gift_items.last
    assert_equal @user.id, gift_item.user_id
  end

  test "商品URLに内部アドレスを指定しても500エラーにならず、手動入力扱いにフォールバックする(SSRF対策)" do
    sign_in @user

    assert_difference -> { @gift_list.gift_items.count }, 1 do
      post gift_list_gift_items_path(@gift_list), params: { gift_item: { url: "http://169.254.169.254/latest/meta-data/" } }
    end

    gift_item = @gift_list.gift_items.last
    assert_equal "商品名を入力してください", gift_item.name
    assert_response :redirect
  end

  test "他人のギフトリストのuuidを指定してもギフトを追加できない(IDOR対策)" do
    sign_in @user

    assert_no_difference -> { GiftItem.count } do
      post gift_list_gift_items_path(@other_gift_list), params: { gift_item: { name: "不正なギフト" } }
    end
  end

  test "他人はギフトの追加画面自体を開けない" do
    sign_in @user

    get new_gift_list_gift_item_path(@other_gift_list)
    assert_redirected_to gift_lists_path
  end

  test "所有者は自分のギフトを削除できるが、他人は削除できない" do
    sign_in @user
    gift_item = @gift_list.gift_items.create!(user: @user, name: "削除対象")

    sign_out @user
    sign_in @other_user
    delete gift_item_path(gift_item)
    assert_response :not_found
    assert GiftItem.exists?(gift_item.id), "他人のギフトが削除されてはいけない"

    sign_out @other_user
    sign_in @user
    assert_difference -> { GiftItem.count }, -1 do
      delete gift_item_path(gift_item)
    end
  end
end
