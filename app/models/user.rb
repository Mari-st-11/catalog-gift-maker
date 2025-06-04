class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :name, presence: true, length: { maximum: 100 }
  has_many :gift_lists, dependent: :destroy
  has_many :gift_items, dependent: :destroy

  def own?(object)
    id == object&.user_id
  end
end
