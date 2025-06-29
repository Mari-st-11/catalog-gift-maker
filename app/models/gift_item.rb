class GiftItem < ApplicationRecord
  validates :url, presence: true, unless: :name?
  validates :name, length: { maximum: 225 }, presence: true, unless: :url?
  enum :status, { unselected: 0, selected: 1 }
  mount_uploader :image, ImageUploader

  belongs_to :user
  belongs_to :gift_list
end
