class AddUuidForeignKey < ActiveRecord::Migration[7.2]
  def change
    add_column :gift_items, :gift_list_uuid, :uuid
  end
end
