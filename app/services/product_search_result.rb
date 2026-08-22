# 楽天/Yahoo!ショッピングAPIの検索結果を統一形式で扱うための入れ物
ProductSearchResult = Struct.new(:name, :image_url, :price, :url, :source, keyword_init: true)
