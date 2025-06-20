class SharedGiftListsController < ApplicationController
  before_action :set_gift_list, only: %i[ show select ]
  before_action :set_gift_item, only: %i[ show select ]

  def show
    @gift_items = @gift_list.gift_items.includes(:user)
  end

  def select
    @selected_gift_item = params[ :gift_item_id ]
    puts "ギフト　id:#{@selected_gift_item}が選択されました"
  end

  private

  def set_gift_list
    @gift_list = current_user.gift_lists.find(params[:id])
  end

  def set_gift_item
    @gift_item = current_user.gift_items.find(params[:id])
  end
end