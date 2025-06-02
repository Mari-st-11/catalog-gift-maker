class GiftListsController < ApplicationController
  def index
    @gift_lists = GiftList.includes(:user)
  end

  def new
    @gift_list = GiftList.new
  end

  def create
    @gift_list = current_user.gift_lists.build(gift_lists_params)

    if @gift_list.save
      redirect_to gift_lists_path(@gift_list)
    end
  end

  private

  def gift_lists_params
    params.require(:gift_list).permit(:recipient_name, :purpose)
  end
end
