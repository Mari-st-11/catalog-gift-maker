class ChangePrimaryKey < ActiveRecord::Migration[7.2]
  def change
    change_column :gift_lists, :uuid, :uuid, using: 'uuid::uuid'
    remove_foreign_key :gift_items, :gift_lists

    execute 'ALTER TABLE gift_lists DROP CONSTRAINT gift_lists_pkey;'
    execute 'ALTER TABLE gift_lists ADD PRIMARY KEY (uuid);'

    add_foreign_key :gift_items, :gift_lists, column: :gift_list_uuid, primary_key: :uuid
  end
end
