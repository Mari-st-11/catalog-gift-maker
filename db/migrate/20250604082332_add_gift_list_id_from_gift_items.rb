class AddGiftListIdFromGiftItems < ActiveRecord::Migration[7.2]
  def change
    add_reference :gift_items, :gift_list, null: false, foreign_key: true
  end
end
