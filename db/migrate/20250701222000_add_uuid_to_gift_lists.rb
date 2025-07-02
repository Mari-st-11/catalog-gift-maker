class AddUuidToGiftLists < ActiveRecord::Migration[7.2]
  def change
    add_column :gift_lists, :uuid, :string
    add_index :gift_lists, :uuid, unique: true
  end
end
