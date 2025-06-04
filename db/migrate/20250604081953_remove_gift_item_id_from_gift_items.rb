class RemoveGiftItemIdFromGiftItems < ActiveRecord::Migration[7.2]
  def change
    remove_reference :gift_items, :gift_item, null: false, foreign_key: true
  end
end
