class SharedGiftListsController < ApplicationController
  layout "public"

  rescue_from ActiveRecord::RecordNotFound, with: :render_link_expired

  before_action :set_gift_list, only: %i[ show choose cancel ]

  def show
    @gift_items = @gift_list.gift_items.includes(:user).order(:id)
  end

  def choose
    unless @gift_list.try_mark_selected!
      redirect_to shared_gift_list_path(@gift_list.public_token), alert: "すでに他のギフトが選択されています"
      return
    end

    @gift_items = @gift_list.gift_items
    @selected_gift_item = @gift_list.gift_items.find(params[:gift_item_id])
    @unselected_gift_items = @gift_list.gift_items.where.not(id: params[:gift_item_id])
    # 選択と同時に確定させる(以前はselected→confirmedの2ステップだったが、
    # 確認ダイアログで意図確認できれば十分なため1ステップに統合した)
    @selected_gift_item.selected!
    @selected_gift_item.confirmed!
    @unselected_gift_items.each do |unselected_gift_item|
      unselected_gift_item.unselected!
    end

    flash[:success] = "#{@gift_list.user.name}さんに通知しました"
    redirect_to shared_gift_list_path(@gift_list.public_token)
  end

  def cancel
    unless current_user == @gift_list.user
      redirect_to shared_gift_list_path(@gift_list.public_token), alert: "この操作は贈り主のみ行えます"
      return
    end

    @selected_gift_item = @gift_list.gift_items.where(status: [ :confirmed ]).first
    @selected_gift_item.unselected!
    # 受け取り主がまた選び直せるよう、shared状態に戻す
    @gift_list.update!(status: :shared)
    redirect_to gift_list_path(@gift_list)
  end

  private

  def set_gift_list
    @gift_list = GiftList.find_by!(public_token: params[:id])
  end

  def render_link_expired
    render "shared/link_expired", status: :not_found
  end
end
