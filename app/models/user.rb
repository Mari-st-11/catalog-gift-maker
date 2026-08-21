class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: %i[google_oauth2 line]

  validates :name, presence: true, length: { maximum: 100 }
  has_many :gift_lists, dependent: :destroy
  has_many :gift_items, dependent: :destroy
  has_many :notifications, dependent: :destroy

  def own?(object)
    id == object&.user_id
  end

  # OmniAuth認証後、既存ユーザーと突き合わせてから作成する。
  # 同じメールアドレスの既存ユーザーがいれば新規作成せず連携する。
  def self.from_omniauth(auth)
    user = find_by(provider: auth.provider, uid: auth.uid)
    return user if user

    user = find_by(email: auth.info.email) if auth.info.email.present?
    if user
      user.update!(provider: auth.provider, uid: auth.uid)
      return user
    end

    create!(
      provider: auth.provider,
      uid: auth.uid,
      email: auth.info.email.presence || "#{auth.provider}-#{auth.uid}@example.invalid",
      name: auth.info.name.presence || "ゲスト",
      password: Devise.friendly_token[0, 20]
    )
  end
end
