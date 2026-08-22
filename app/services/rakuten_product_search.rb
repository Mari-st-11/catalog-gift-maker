# 楽天市場商品検索API(IchibaItem/Search)を呼び出す。
# RAKUTEN_APPLICATION_ID が未設定、またはAPIが失敗した場合は空配列を返す
# (呼び出し側で「片方が失敗しても動く」フォールバックを実現するため)。
class RakutenProductSearch
  ENDPOINT = "https://app.rakuten.co.jp/services/api/IchibaItem/Search/20220601"
  TIMEOUT_SECONDS = 3

  def self.search(keyword, limit: 10)
    application_id = ENV["RAKUTEN_APPLICATION_ID"]
    return [] if application_id.blank? || keyword.blank?

    uri = URI(ENDPOINT)
    uri.query = URI.encode_www_form(
      applicationId: application_id,
      keyword: keyword,
      hits: limit,
      format: "json"
    )

    parse(fetch(uri))
  rescue StandardError => e
    Rails.logger.warn("RakutenProductSearch failed: #{e.class}: #{e.message}")
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
    (json["Items"] || []).filter_map do |wrapper|
      item = wrapper["Item"]
      next if item.blank?

      ProductSearchResult.new(
        name: item["itemName"],
        image_url: item.dig("mediumImageUrls", 0, "imageUrl"),
        price: item["itemPrice"],
        url: item["itemUrl"],
        source: "rakuten"
      )
    end
  end
  private_class_method :parse
end
