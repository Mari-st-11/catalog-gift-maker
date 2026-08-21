# 商品URL(ユーザー入力)からOGP情報・画像を取得する際のSSRF対策。
# - http/httpsのみ許可
# - プライベートIP・クラウドメタデータアドレス(169.254.169.254等)への接続を拒否
#   (リダイレクト先に対しても同様にチェックする。ssrf_filter gemがホスト名をIPに解決した上で
#   直接そのIPに接続するため、DNS Rebinding対策も兼ねている)
# - タイムアウトは最大2秒、取得サイズは最大1MBに制限
class SafeHtmlFetcher
  MAX_BYTES = 1 * 1024 * 1024
  TIMEOUT_SECONDS = 2
  USER_AGENT = "Mozilla/5.0 (compatible; CatalogGiftMakerBot/1.0)"

  class FetchError < StandardError; end

  # HTML/画像などのレスポンスボディを、サイズ上限付きで取得する
  def self.fetch(url)
    body = +""

    response = SsrfFilter.get(
      url,
      scheme_whitelist: %w[http https],
      http_options: { open_timeout: TIMEOUT_SECONDS, read_timeout: TIMEOUT_SECONDS },
      headers: { "User-Agent" => USER_AGENT }
    ) do |res|
      body = +""
      res.read_body do |chunk|
        body << chunk
        raise FetchError, "response exceeded #{MAX_BYTES} bytes" if body.bytesize > MAX_BYTES
      end
    end

    raise FetchError, "unexpected response status #{response.code}" unless response.is_a?(Net::HTTPSuccess)

    body
  rescue SsrfFilter::Error, URI::InvalidURIError, SocketError, Net::OpenTimeout, Net::ReadTimeout, IOError => e
    raise FetchError, e.message
  end

  # 画像などバイナリを、CarrierWaveにmountできるIOオブジェクトとして取得する
  def self.fetch_as_io(url)
    body = fetch(url)
    filename = File.basename(URI.parse(url).path.to_s)
    filename = "download" if filename.blank?

    io = StringIO.new(body)
    io.define_singleton_method(:original_filename) { filename }
    io
  end
end
