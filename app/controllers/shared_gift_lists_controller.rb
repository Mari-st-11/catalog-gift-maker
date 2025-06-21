class SharedGiftListsController < ApplicationController
  before_action :set_gift_list, only: %i[ show choose ]
  before_action :set_gift_item, only: %i[ show choose ]

  def show
    @gift_items = @gift_list.gift_items.includes(:user).order(:id)
  end

  def choose
    @selected_gift_item = @gift_list.gift_items.find(params[:gift_item_id])
    puts "ギフトid: #{@selected_gift_item.id}が選択されました"
    @selected_gift_item.selected!

    @unselected_gift_items = @gift_list.gift_items.where.not(id: params[:gift_item_id])

    @unselected_gift_items.each do |unselected_gift_item|
      puts "#{unselected_gift_item.id}の状態は#{unselected_gift_item.status}です"
      unselected_gift_item.unselected!
    end
    
    puts "状態は#{@selected_gift_item.status}です"
    
    redirect_to action: :show
  end

  private

  def set_gift_list
    @gift_list = GiftList.find(params[:id])
  end

  def set_gift_item
    @gift_item = GiftItem.find(params[:id])
  end
end