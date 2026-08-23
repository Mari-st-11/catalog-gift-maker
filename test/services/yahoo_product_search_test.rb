require "test_helper"

class YahooProductSearchTest < ActiveSupport::TestCase
  SAMPLE_RESPONSE = {
    hits: [
      {
        name: "電動ミル付きコーヒーメーカー",
        price: 5980,
        url: "https://store.shopping.yahoo.co.jp/shop/coffee-mill.html",
        image: { small: "https://item-shopping.c.yimg.jp/small.jpg", medium: "https://item-shopping.c.yimg.jp/medium.jpg" },
        seller: { name: "コーヒー専門店" }
      }
    ]
  }.to_json

  test "APIキー未設定の場合は空配列を返す" do
    ENV.delete("YAHOO_CLIENT_ID")
    assert_equal [], YahooProductSearch.search("コーヒー")
  end

  test "正常なレスポンスを統一フォーマットに変換する" do
    ENV["YAHOO_CLIENT_ID"] = "dummy-client-id"
    YahooProductSearch.stub(:fetch, SAMPLE_RESPONSE) do
      results = YahooProductSearch.search("コーヒー")

      assert_equal 1, results.size
      result = results.first
      assert_equal "電動ミル付きコーヒーメーカー", result.name
      assert_equal 5980, result.price
      assert_equal "https://store.shopping.yahoo.co.jp/shop/coffee-mill.html", result.url
      assert_equal "https://item-shopping.c.yimg.jp/medium.jpg", result.image_url
      assert_equal "コーヒー専門店", result.shop_name
      assert_equal "yahoo", result.source
    end
  ensure
    ENV.delete("YAHOO_CLIENT_ID")
  end

  test "API呼び出しが失敗しても例外を出さず空配列を返す" do
    ENV["YAHOO_CLIENT_ID"] = "dummy-client-id"
    YahooProductSearch.stub(:fetch, ->(_uri) { raise "network error" }) do
      assert_equal [], YahooProductSearch.search("コーヒー")
    end
  ensure
    ENV.delete("YAHOO_CLIENT_ID")
  end
end
