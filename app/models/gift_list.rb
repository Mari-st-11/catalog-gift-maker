class GiftList < ApplicationRecord
  before_create :set_uuid
  before_create :set_public_token

  validates :recipient_name, presence: true, length: { maximum: 255 }
  validates :purpose, length: { maximum: 255 }
  enum :cover_image, { default: 0, birthday: 1 }

  # デザインテーマ（着せ替え）
  enum :theme, { mode: 0, botanical: 1, nuance: 2 }

  # draft: 作成中 / shared: 共有済み(未選択) / selected: 選択済み / completed: プレゼント完了
  enum :status, { draft: 0, shared: 1, selected: 2, completed: 3 }

  validates :public_name, length: { maximum: 255 }
  validates :content, length: { maximum: 80 }

  belongs_to :user
  has_many :gift_items, primary_key: :uuid, foreign_key: :gift_list_uuid, dependent: :destroy

  # 受け取り主による商品選択（二重送信・競合状態対策）。
  # まだ選択されていない(draft/shared)場合だけ selected に1回だけ更新できる。
  # 同時に2回リクエストが来ても、更新できるのはどちらか一方だけになる。
  def try_mark_selected!
    self.class.where(uuid: uuid, status: [ :draft, :shared ])
        .update_all(status: GiftList.statuses[:selected]) == 1
  end

  # 共有リンクが漏れた・不安になった場合に、カタログ本体はそのままにリンクだけ無効化する
  def regenerate_public_token!
    update!(public_token: SecureRandom.urlsafe_base64(16))
  end

  private

  def set_uuid
    self.uuid = SecureRandom.uuid
  end

  def set_public_token
    self.public_token = SecureRandom.urlsafe_base64(16)
  end
end
