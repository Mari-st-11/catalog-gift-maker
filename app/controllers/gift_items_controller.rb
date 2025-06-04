class GiftItemsController < ApplicationController

  def new
    @gift_item = GiftItem.new
  end

  def create
    @gift_item = gift_lists.gift_items.build(gift_item_params)
    if @gift_item.save
      redirect_to gift_item
    end
  end

  private

  def gift_item_params
    params.require(:gift_item)
  end
end