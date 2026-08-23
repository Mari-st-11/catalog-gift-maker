class SharedGiftItemsController < ApplicationController
  layout "public"

  rescue_from ActiveRecord::RecordNotFound, with: :render_link_expired

  def show
    # ネストされたshared_gift_list_id(public_token)経由でしか辿れないようにする。
    # gift_item.idだけで探すと連番IDの総当たりで全ユーザーの全アイテムが閲覧できてしまう。
    gift_list = GiftList.find_by!(public_token: params[:shared_gift_list_id])
    @gift_item = gift_list.gift_items.find(params[:id])
  end

  private

  def render_link_expired
    render "shared/link_expired", status: :not_found
  end
end
