class SharedGiftListsController < ApplicationController
  before_action :set_gift_list, only: %i[ show ]
  before_action :set_gift_item, only: %i[ show ]

  def show
    @gift_items = @gift_list.gift_items.includes(:user)
  end

  private

  def set_gift_list
    @gift_list = current_user.gift_lists.find(params[:id])
  end

  def set_gift_item
    @gift_item = current_user.gift_items.find(params[:id])
  end
end