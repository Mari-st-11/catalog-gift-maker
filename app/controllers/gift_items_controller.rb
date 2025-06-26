class GiftItemsController < ApplicationController
  before_action :set_gift_item, only: %i[ show edit update destroy ]

  def new
    @gift_item = GiftItem.new
  end

  def create
    require "open-uri"
    @gift_item = current_user.gift_items.build(gift_item_params)

    html = URI.open(@gift_item.url).read
    doc = Nokogiri::HTML.parse(html)

    @gift_item.name = doc.css('meta[property="og:title"] @content').to_s
    @gift_item.description = doc.css('meta[property="og:description"] @content').to_s
    image_url = doc.css('meta[property="og:image"] @content').to_s # 画像URLをテキストで保存
    file = URI.open(image_url) # 画像をオブジェクトに

    @gift_item.image = file

    if @gift_item.save
      redirect_to gift_item_path(@gift_item)
    end
  end

  def show; end

  def edit; end

  def update
    if @gift_item.update(gift_item_params_update)
      redirect_to gift_item_path(@gift_item)
    end
  end

  def destroy
    # @gift_list = GiftList.find(params[:id])
    @gift_item.destroy!
    redirect_to gift_lists_path
  end

  private

  def gift_item_params
    params.require(:gift_item).permit(:url, :name, :description, :image).merge(gift_list_id: params[:gift_list_id])
  end

  def gift_item_params_update
    params.require(:gift_item).permit(:url, :name, :description)
  end

  def set_gift_item
    @gift_item = current_user.gift_items.find(params[:id])
  end
end
