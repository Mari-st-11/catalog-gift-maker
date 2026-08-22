# 楽天/Yahoo!ショッピングを並列に検索し、結果をまとめて返す。
# 片方のAPIが失敗しても、各クライアントが空配列を返すだけなので
# もう片方の結果は問題なく表示される。
class ProductSearch
  def self.call(keyword)
    return [] if keyword.blank?

    threads = {
      rakuten: Thread.new { RakutenProductSearch.search(keyword) },
      yahoo: Thread.new { YahooProductSearch.search(keyword) }
    }

    threads.values.flat_map(&:value)
  end
end
