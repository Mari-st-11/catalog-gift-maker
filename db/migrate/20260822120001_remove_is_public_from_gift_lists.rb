# is_public(boolean)とstatus(enum)が同じ「公開状態」を別々に表しており、
# 今後食い違って矛盾したデータになるリスクがあったため、statusに一本化する。
# is_publicはバリデーション以外どこからも参照・更新されていなかったため、
# 素直に削除してよいと判断した。
class RemoveIsPublicFromGiftLists < ActiveRecord::Migration[7.2]
  def change
    remove_column :gift_lists, :is_public, :boolean, default: true
  end
end
