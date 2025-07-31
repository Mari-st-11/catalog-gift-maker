class AddMessageToGiftLists < ActiveRecord::Migration[7.2]
  def change
    add_column :gift_lists, :message, :string, null: true
  end
end
