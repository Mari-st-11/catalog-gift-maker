class AddThemeAndStatusToGiftLists < ActiveRecord::Migration[7.2]
  def change
    # theme: カタログのデザインテーマ（mode / botanical / nuance）
    add_column :gift_lists, :theme, :integer, default: 0, null: false
    # status: draft(作成中) / shared(共有済み) / selected(選択済み) / completed(完了)
    # is_public は当面残すが、今後は status に一本化していく想定
    add_column :gift_lists, :status, :integer, default: 0, null: false

    add_index :gift_lists, :status
  end
end
