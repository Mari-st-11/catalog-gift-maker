class AddExternalImageUrlToGiftItems < ActiveRecord::Migration[7.2]
  def change
    add_column :gift_items, :external_image_url, :string
  end
end
