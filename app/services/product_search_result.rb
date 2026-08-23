# 楽天/Yahoo!ショッピングAPIの検索結果を統一形式で扱うための入れ物
# image_url: 検索結果一覧に表示する小さいサムネイル
# full_image_url: 「カタログに追加」時に実際に保存する高解像度版
ProductSearchResult = Struct.new(:name, :image_url, :full_image_url, :price, :shop_name, :url, :source, keyword_init: true)
