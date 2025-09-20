class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.references :user, foreign_key: true
      t.references :gift_item, foreign_key: true
      t.boolean :is_read, null: false, default: false

      t.timestamps
    end
  end
end
