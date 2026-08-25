require "test_helper"

class GiftItemTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(name: "贈り主", email: "sender2@example.com", password: "password123")
    @gift_list = @user.gift_lists.create!(recipient_name: "お父さん")
    @gift_item = @user.gift_items.create!(gift_list: @gift_list, name: "マグカップ", price: 2000)
  end

  test "selectedに変わったら、gift_listの持ち主に通知が作られる" do
    assert_difference -> { Notification.count }, 1 do
      @gift_item.update!(status: :selected)
    end

    notification = Notification.last
    assert_equal @user.id, notification.user_id
    assert_equal @gift_item.id, notification.gift_item_id
  end

  test "selected以外への変更では通知が作られない" do
    assert_no_difference -> { Notification.count } do
      @gift_item.update!(status: :unselected)
    end
  end

  test "priceは0以上の整数のみ許可される" do
    @gift_item.price = -100
    assert_not @gift_item.valid?

    @gift_item.price = nil
    assert @gift_item.valid?
  end

  test "display_image_urlはexternal_image_urlしかない場合そちらを返す" do
    @gift_item.external_image_url = "https://example.com/item.jpg"
    assert_equal "https://example.com/item.jpg", @gift_item.display_image_url
  end

  test "display_image_urlはimageが添付されていればexternal_image_urlより優先する" do
    @gift_item.external_image_url = "https://example.com/item.jpg"
    fake_io = StringIO.new("fake image body")
    fake_io.define_singleton_method(:original_filename) { "uploaded.jpg" }
    @gift_item.image = fake_io
    @gift_item.save!

    assert_match "uploaded.jpg", @gift_item.display_image_url
  end
end
