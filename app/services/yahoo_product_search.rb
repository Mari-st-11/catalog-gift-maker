# Yahoo!ショッピングAPI(itemSearch)を呼び出す。
# YAHOO_CLIENT_ID が未設定、またはAPIが失敗した場合は空配列を返す
# (呼び出し側で「片方が失敗しても動く」フォールバックを実現するため)。
class YahooProductSearch
  ENDPOINT = "https://shopping.yahooapis.jp/ShoppingWebService/V3/itemSearch"
  TIMEOUT_SECONDS = 3

  def self.search(keyword, limit: 10, page: 1)
    client_id = ENV["YAHOO_CLIENT_ID"]
    return [] if client_id.blank? || keyword.blank?

    uri = URI(ENDPOINT)
    uri.query = URI.encode_www_form(
      appid: client_id,
      query: keyword,
      results: limit,
      start: ((page - 1) * limit) + 1
    )

    parse(fetch(uri))
  rescue StandardError => e
    Rails.logger.warn("YahooProductSearch failed: #{e.class}: #{e.message}")
    []
  end

  def self.fetch(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = TIMEOUT_SECONDS
    http.read_timeout = TIMEOUT_SECONDS

    response = http.get(uri.request_uri)
    raise "unexpected response status #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    response.body
  end
  private_class_method :fetch

  def self.parse(body)
    json = JSON.parse(body)
    (json["hits"] || []).filter_map do |item|
      next if item.blank?

      ProductSearchResult.new(
        name: item["name"],
        image_url: item.dig("image", "medium"),
        price: item["price"],
        shop_name: item.dig("seller", "name"),
        url: item["url"],
        source: "yahoo"
      )
    end
  end
  private_class_method :parse
end
