class GiftItem < ApplicationRecord
  validates: url, length: { maximum: 535 }
  validates: name, length: { maximum: 225 }
  validates: description, length: { maximum: 225 }
  validate: status
  enum status: { unchoice: 0, choice: 1 }

  belongs_to :user
  belongs_to :gift_list
end
