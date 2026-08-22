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
    assert gift_item.manual?
  end

  test "商品名検索(楽天/Yahoo横断検索)の結果がturbo_streamで返る" do
    sign_in @user
    result = ProductSearchResult.new(name: "テスト商品", price: 1000, url: "https://example.com/item", image_url: "https://example.com/item.jpg", source: "rakuten")

    ProductSearch.stub(:call, [ result ]) do
      get search_gift_list_gift_items_path(@gift_list), params: { keyword: "テスト" }, as: :turbo_stream
    end

    assert_response :success
    assert_match "テスト商品", response.body
  end

  test "API検索結果から選んだ商品はsource_type: api_searchとして登録される" do
    sign_in @user

    fake_io = StringIO.new("fake image body")
    fake_io.define_singleton_method(:original_filename) { "item.jpg" }

    SafeHtmlFetcher.stub(:fetch_as_io, fake_io) do
      assert_difference -> { @gift_list.gift_items.count }, 1 do
        post gift_list_gift_items_path(@gift_list), params: {
          gift_item: { name: "コーヒーメーカー", url: "https://example.com/item", price: 3980 },
          image_url: "https://example.com/item.jpg"
        }
      end
    end

    gift_item = @gift_list.gift_items.last
    assert gift_item.api_search?
    assert_equal 3980, gift_item.price
  end

  test "商品URLに内部アドレスを指定しても500エラーにならず、手動入力扱いにフォールバックする(SSRF対策)" do
    sign_in @user

    assert_difference -> { @gift_list.gift_items.count }, 1 do
      post gift_list_gift_items_path(@gift_list), params: { gift_item: { url: "http://169.254.169.254/latest/meta-data/" } }
    end

    gift_item = @gift_list.gift_items.last
    assert_equal "商品名を入力してください", gift_item.name
    assert gift_item.url_ogp?
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
