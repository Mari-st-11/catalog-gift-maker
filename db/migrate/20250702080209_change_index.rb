class ChangeIndex < ActiveRecord::Migration[7.2]
  def change
    remove_index :gift_items, name: 'index_gift_items_on_gift_list_id'

    add_index :gift_items, :gift_list_uuid
  end
end
