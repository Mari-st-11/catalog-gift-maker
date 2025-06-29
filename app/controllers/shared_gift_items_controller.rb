class SharedGiftItemsController < ApplicationController
  def show
    @gift_item = GiftItem.find(params[:id])
  end
end
