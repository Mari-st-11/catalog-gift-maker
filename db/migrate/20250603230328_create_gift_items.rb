class CreateGiftItems < ActiveRecord::Migration[7.2]
  def change
    create_table :gift_items do |t|
      t.text :url
      t.string :name
      t.text :description
      t.string :image
      t.integer :status

      t.references :user, foreign_key: true
      t.references :gift_item, foreign_key: true
      t.timestamps
    end
  end
end
