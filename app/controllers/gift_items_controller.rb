class GiftItemsController < ApplicationController

  def new
    @gift_item = GiftItem.new
  end

  def create
    @gift_item = current_user.gift_items.build(gift_item_params)
    if @gift_item.save
      redirect_to root_path
    end
  end

  private

  def gift_item_params
    params.require(:gift_item).permit(:url, :name, :description, :image).merge(gift_list_id: params[:gift_list_id])
  end

end