class GiftItem < ApplicationRecord
  validates :url, presence: true, unless: :name?, format: /\A#{URI.regexp(%w[http https])}\z/
  validates :name, length: { maximum: 225 }, presence: true, unless: :url?
  enum :status, { unselected: 0, selected: 1, confirmed: 2 }
  mount_uploader :image, ImageUploader

  belongs_to :user
  belongs_to :gift_list, primary_key: :uuid, foreign_key: :gift_list_uuid
end
