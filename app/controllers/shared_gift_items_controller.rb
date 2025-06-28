class SharedGiftItemsController < ApplicationController
  def show
    #@gift_list = GiftList.find(params[:id])
    @gift_item = GiftItem.find(params[:id])
  end
end