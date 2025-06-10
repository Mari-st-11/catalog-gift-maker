class GiftItemsController < ApplicationController

  def new
    @gift_item = GiftItem.new
    # ↓あとでやる 
    # @gift_list = GiftList.find_by(id: @gift_item.gift_list_id)
  end

  def create
    @gift_item = current_user.gift_items.build(gift_item_params)
    if @gift_item.save
      redirect_to gift_item
    end
  end

  private

  def gift_item_params
    params.require(:gift_item)
  end

end