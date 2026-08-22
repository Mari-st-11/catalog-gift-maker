require "test_helper"

class SharedGiftItemsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(name: "贈り主", email: "owner3@example.com", password: "password123")
    @gift_list = @user.gift_lists.create!(recipient_name: "お母さん")
    @gift_item = @gift_list.gift_items.create!(user: @user, name: "マグカップ", description: "説明文")

    @other_user = User.create!(name: "他人", email: "other3@example.com", password: "password123")
    @other_gift_list = @other_user.gift_lists.create!(recipient_name: "友人")
    @other_gift_item = @other_gift_list.gift_items.create!(user: @other_user, name: "他人のギフト", description: "説明文")
  end

  test "正しいpublic_tokenと組み合わせればギフトの詳細を閲覧できる" do
    get shared_gift_list_shared_gift_item_path(@gift_list.public_token, @gift_item)
    assert_response :success
  end

  test "gift_item.idだけ合っていても、紐付かないshared_gift_list_idでは閲覧できない(連番ID総当たり対策)" do
    get shared_gift_list_shared_gift_item_path(@other_gift_list.public_token, @gift_item)
    assert_response :not_found
  end
end
