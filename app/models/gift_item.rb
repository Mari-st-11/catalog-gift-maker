class GiftItem < ApplicationRecord
  validates :url, presence: true, unless: :name?, length: { maximum: 535 }
  validates :name, length: { maximum: 225 }, presence: true, unless: :url?
  validates :description, length: { maximum: 225 }
  enum :status, { unchoice: 0, choice: 1 }

  has_one_attached :image

  belongs_to :user
  belongs_to :gift_list
end
