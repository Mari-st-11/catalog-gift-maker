class SharedGiftListsController < ApplicationController
  before_action :set_gift_list, only: %i[ show choose confirm cancel ]

  def show
    @gift_items = @gift_list.gift_items.includes(:user).order(:id)
  end

  def choose
    @gift_items = @gift_list.gift_items
    @selected_gift_item = @gift_list.gift_items.find(params[:gift_item_id])
    @unselected_gift_items = @gift_list.gift_items.where.not(id: params[:gift_item_id])
    # 選択されたアイテムのstatusをselectedに変更
    @selected_gift_item.selected!
    # 選択されなかったアイテムのstatusをunselectedに変更
    @unselected_gift_items.each do |unselected_gift_item|
      unselected_gift_item.unselected!
    end
    redirect_to shared_gift_list_path(@gift_list)
  end

  def confirm
    @selected_gift_item = @gift_list.gift_items.where(status: [ :selected ]).first
    @selected_gift_item.confirmed!

    flash[:success] = '贈り主に通知を行いました'
    redirect_to shared_gift_list_path(@gift_list)
  end

  def cancel
    @selected_gift_item = @gift_list.gift_items.where(status: [ :confirmed ]).first
    @selected_gift_item.unselected!
    redirect_to gift_list_path(@gift_list)
  end

  private

  def set_gift_list
    @gift_list = GiftList.find_by(uuid: params[:id])
  end
end
