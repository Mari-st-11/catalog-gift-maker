class CreateGiftLists < ActiveRecord::Migration[7.2]
  def change
    create_table :gift_lists do |t|
      t.string :recipient_name, null: false
      t.string :purpose
      t.integer :cover_image
      t.string :public_name
      t.boolean :is_public, default: true # true == 公開
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
