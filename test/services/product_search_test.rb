require "test_helper"

class ProductSearchTest < ActiveSupport::TestCase
  test "キーワードが空なら空配列を返す" do
    assert_equal [], ProductSearch.call("")
    assert_equal [], ProductSearch.call(nil)
  end

  test "楽天とYahooの結果を両方まとめて返す" do
    rakuten_result = ProductSearchResult.new(name: "楽天の商品", source: "rakuten")
    yahoo_result = ProductSearchResult.new(name: "Yahooの商品", source: "yahoo")

    RakutenProductSearch.stub(:search, [ rakuten_result ]) do
      YahooProductSearch.stub(:search, [ yahoo_result ]) do
        results = ProductSearch.call("コーヒー")

        assert_equal 2, results.size
        assert_includes results, rakuten_result
        assert_includes results, yahoo_result
      end
    end
  end

  test "片方のAPIが失敗して空配列を返しても、もう片方の結果は返る" do
    yahoo_result = ProductSearchResult.new(name: "Yahooの商品", source: "yahoo")

    RakutenProductSearch.stub(:search, []) do
      YahooProductSearch.stub(:search, [ yahoo_result ]) do
        results = ProductSearch.call("コーヒー")

        assert_equal [ yahoo_result ], results
      end
    end
  end
end
