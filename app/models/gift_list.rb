class GiftList < ApplicationRecord
  validates :recipient_name, presence: true, length: { maximum: 255 }
  validates :purpose, length: { maximum: 255 }
  enum cover_image: { default: 0, birthday: 1 }
  validates :public_name, length: { maximum: 255 }
  validates :is_public, inclusion: [true, false]

  belongs_to :user
end
