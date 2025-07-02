class DeleteUserIdAndPostId < ActiveRecord::Migration[7.2]
  def change
    remove_column :gift_items, :gift_list_id, :bigint

    remove_column :gift_lists, :id, :bigserial
  end
end
