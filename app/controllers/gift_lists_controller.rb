class GiftListsController < ApplicationController
  before_action :authenticate_user!, except: %i[ index ]
  before_action :set_gift_list, only: %i[ show edit update destroy regenerate_public_token ]
  def index
    @gift_lists = current_user.gift_lists.includes(:user, :gift_items).order(created_at: :desc) if user_signed_in?
  end

  def show
    @gift_items = @gift_list.gift_items.includes(:user).order(:id)
    @selected_gift_item = @gift_list.gift_items.where(status: [ :selected, :confirmed ]).first
  end

  def new
    @gift_list = GiftList.new
  end

  def create
    @gift_list = current_user.gift_lists.build(gift_list_params)

    if @gift_list.save
      redirect_to new_gift_list_gift_item_path(@gift_list)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @gift_list.update(gift_list_params)
      redirect_to gift_list_path(@gift_list)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @gift_list.destroy!
    redirect_to gift_lists_path
  end

  def regenerate_public_token
    @gift_list.regenerate_public_token!
    redirect_to gift_list_path(@gift_list), notice: "共有リンクを再発行しました。今までのリンクは使えなくなります"
  end

  private

  def set_gift_list
    @gift_list = current_user.gift_lists.find_by!(uuid: params[:uuid])
  end

  def gift_list_params
    params.require(:gift_list).permit(:recipient_name, :purpose, :content)
  end
end
