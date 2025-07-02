class SharedGiftListsController < ApplicationController
  before_action :set_gift_list, only: %i[ show choose ]
  # before_action :set_gift_item, only: %i[ show choose ]

  def show
    @gift_items = @gift_list.gift_items.includes(:user).order(:id)
  end

  def choose
    @selected_gift_item = @gift_list.gift_items.find(params[:gift_item_id])
    # 選択されたアイテムのstatusをselectedに変更
    @selected_gift_item.selected!

    @unselected_gift_items = @gift_list.gift_items.where.not(id: params[:gift_item_id])
    # 選択されなかったアイテムのstatusをunselectedに変更
    @unselected_gift_items.each do |unselected_gift_item|
      unselected_gift_item.unselected!
    end
  end

  private

  def set_gift_list
    @gift_list = GiftList.find_by(params[:uuid])
  end

  # def set_gift_item
  #   @gift_item = @gift_list.gift_items.find(params[:id])
  # end
end
