class SharedGiftListsController < ApplicationController
  before_action :set_gift_list, only: %i[ show choose confirm ]

  def show
    @gift_items = @gift_list.gift_items.includes(:user).order(:id)
  end

  def choose
    @selected_gift_item = @gift_list.gift_items.find(params[:gift_item_id])
    @unselected_gift_items = @gift_list.gift_items.where.not(id: params[:gift_item_id])
    # 選択されたアイテムのstatusをselectedに変更
    @selected_gift_item.selected!
    # 選択されなかったアイテムのstatusをunselectedに変更
    @unselected_gift_items.each do |unselected_gift_item|
      unselected_gift_item.unselected!
    end
  end

  def confirm
    @selected_gift_item = @gift_list.gift_items.where(status: [ :selected ]).first
    puts "選択されたギフトは#{@selected_gift_item.name}です"
      # statusを確定に変更する
      @selected_gift_item.confirmed!
  end

  private

  def set_gift_list
    @gift_list = GiftList.find_by(uuid: params[:id])
  end
end
