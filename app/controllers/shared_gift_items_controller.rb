class SharedGiftListsController < ApplicationController
  def show
    @gift_item = GiftList.gift_items.find(params[:id])
    
  end
end