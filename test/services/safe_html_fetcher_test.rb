require "test_helper"

class SafeHtmlFetcherTest < ActiveSupport::TestCase
  test "ループバックアドレスへのアクセスは拒否される(SSRF対策)" do
    assert_raises(SafeHtmlFetcher::FetchError) do
      SafeHtmlFetcher.fetch("http://127.0.0.1/")
    end
  end

  test "クラウドメタデータアドレスへのアクセスは拒否される(SSRF対策)" do
    assert_raises(SafeHtmlFetcher::FetchError) do
      SafeHtmlFetcher.fetch("http://169.254.169.254/latest/meta-data/")
    end
  end

  test "プライベートネットワーク(10.0.0.0/8等)へのアクセスは拒否される" do
    assert_raises(SafeHtmlFetcher::FetchError) do
      SafeHtmlFetcher.fetch("http://10.0.0.1/")
    end
  end

  test "http/https以外のスキームは拒否される" do
    assert_raises(SafeHtmlFetcher::FetchError) do
      SafeHtmlFetcher.fetch("file:///etc/passwd")
    end
  end
end
