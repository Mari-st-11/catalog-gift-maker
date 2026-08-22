# 公開URL用のトークンを主キー(uuid)から分離する。
# リンクが漏れて不安になった場合、uuid(内部識別子・gift_itemsからの外部キー)を
# 変えずに public_token だけ再発行できるようにするため。
class AddPublicTokenToGiftLists < ActiveRecord::Migration[7.2]
  def up
    add_column :gift_lists, :public_token, :string
    add_index :gift_lists, :public_token, unique: true

    execute("SELECT uuid FROM gift_lists").each do |row|
      token = connection.quote(SecureRandom.urlsafe_base64(16))
      uuid = connection.quote(row["uuid"])
      execute("UPDATE gift_lists SET public_token = #{token} WHERE uuid = #{uuid}")
    end

    change_column_null :gift_lists, :public_token, false
  end

  def down
    remove_column :gift_lists, :public_token
  end
end
