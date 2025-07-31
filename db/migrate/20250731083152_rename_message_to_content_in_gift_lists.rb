class RenameMessageToContentInGiftLists < ActiveRecord::Migration[7.2]
  def change
    rename_column :gift_lists, :message, :content
  end
end
