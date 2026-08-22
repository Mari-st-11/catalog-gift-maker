require "test_helper"

class RakutenProductSearchTest < ActiveSupport::TestCase
  SAMPLE_RESPONSE = {
    Items: [
      {
        Item: {
          itemName: "コーヒーメーカー",
          itemPrice: 3980,
          itemUrl: "https://item.rakuten.co.jp/shop/coffee-maker/",
          mediumImageUrls: [ { imageUrl: "https://thumbnail.image.rakuten.co.jp/coffee.jpg" } ]
        }
      }
    ]
  }.to_json

  test "APIキー未設定の場合は空配列を返す" do
    ENV.delete("RAKUTEN_APPLICATION_ID")
    assert_equal [], RakutenProductSearch.search("コーヒー")
  end

  test "正常なレスポンスを統一フォーマットに変換する" do
    ENV["RAKUTEN_APPLICATION_ID"] = "dummy-app-id"
    RakutenProductSearch.stub(:fetch, SAMPLE_RESPONSE) do
      results = RakutenProductSearch.search("コーヒー")

      assert_equal 1, results.size
      result = results.first
      assert_equal "コーヒーメーカー", result.name
      assert_equal 3980, result.price
      assert_equal "https://item.rakuten.co.jp/shop/coffee-maker/", result.url
      assert_equal "https://thumbnail.image.rakuten.co.jp/coffee.jpg", result.image_url
      assert_equal "rakuten", result.source
    end
  ensure
    ENV.delete("RAKUTEN_APPLICATION_ID")
  end

  test "API呼び出しが失敗しても例外を出さず空配列を返す" do
    ENV["RAKUTEN_APPLICATION_ID"] = "dummy-app-id"
    RakutenProductSearch.stub(:fetch, ->(_uri) { raise "network error" }) do
      assert_equal [], RakutenProductSearch.search("コーヒー")
    end
  ensure
    ENV.delete("RAKUTEN_APPLICATION_ID")
  end
end
