class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :gift_item

  scope :unread, -> { where(is_read: false) }
  scope :read, -> { where(is_read: true) }

  def mark_as_read!
    update!(is_read: true)
  end
end
