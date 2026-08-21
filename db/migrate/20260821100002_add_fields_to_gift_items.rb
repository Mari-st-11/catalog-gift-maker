class AddFieldsToGiftItems < ActiveRecord::Migration[7.2]
  def change
    # 金額。/c/:token 経由のレスポンスからは必ず除外すること（コントローラ側で担保）
    add_column :gift_items, :price, :integer

    # 商品データの登録経路: api_search(API横断検索) / url_ogp(URL入力+OGP取得) / manual(手動入力)
    add_column :gift_items, :source_type, :integer, default: 2, null: false

    # 楽天/YahooのアフィリエイトURL（url カラムは引き続き「購入先URL」として使用）
    add_column :gift_items, :affiliate_url, :text

    add_index :gift_items, :source_type
  end
end
