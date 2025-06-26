class GiftListsController < ApplicationController
  before_action :set_gift_list, only: %i[ show edit update ]
  def index
    @gift_lists = current_user.gift_lists.includes(:user).order(:id) if user_signed_in?
  end

  def show
    @gift_items = @gift_list.gift_items.includes(:user).order(:id)
    @selected_gift_item = @gift_list.gift_items.where(status: [ :selected ]).first
  end

  def new
    @gift_list = GiftList.new
  end

  def create
    @gift_list = current_user.gift_lists.build(gift_list_params)

    if @gift_list.save
      redirect_to gift_lists_path(@gift_list)
    end
  end

  def edit; end

  def update
    if @gift_list.update(gift_list_params)
      redirect_to gift_lists_path(@gift_list)
    end
  end

  private

  def set_gift_list
    @gift_list = current_user.gift_lists.find(params[:id])
  end

  def gift_list_params
    params.require(:gift_list).permit(:recipient_name, :purpose)
  end
end
