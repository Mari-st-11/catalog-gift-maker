class GiftItem < ApplicationRecord
  validates :url, presence: true, unless: :name?, format: /\A#{URI.regexp(%w[http https])}\z/
  validates :name, length: { maximum: 225 }, presence: true, unless: :url?
  validates :price, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true

  enum :status, { unselected: 0, selected: 1, confirmed: 2 }
  # 商品データの登録経路: api_search(API横断検索) / url_ogp(URL入力+OGP取得) / manual(手動入力)
  enum :source_type, { api_search: 0, url_ogp: 1, manual: 2 }

  mount_uploader :image, ImageUploader

  belongs_to :user
  belongs_to :gift_list, primary_key: :uuid, foreign_key: :gift_list_uuid
  has_many :notifications, dependent: :destroy

  # 受け取り主が商品を選択したら、贈り主への通知レコードを作成する
  # (LINE通知の送信はNotificationモデル側/専用サービスで後続実装)
  after_update :create_notification, if: :saved_change_to_status?

  private

  def create_notification
    return unless selected?

    Notification.create!(user: gift_list.user, gift_item: self)
  end
end
