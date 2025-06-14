class GiftItemsController < ApplicationController
  before_action :set_gift_item, only: %i[ show edit update ]

  def new
    @gift_item = GiftItem.new
  end

  def create
    require 'open-uri'
    @gift_item = current_user.gift_items.build(gift_item_params)

    html = URI.open(@gift_item.url).read
    doc = Nokogiri::HTML.parse(html)

    @gift_item.name = doc.css('meta[property="og:title"] @content').to_s
    @gift_item.description = doc.css('meta[property="og:description"] @content').to_s
    image = doc.css('meta[property="og:image"] @content').to_s
    @gift_item.image.attach(io: URI.open(image), filename: image)

    if @gift_item.save
      redirect_to root_path
    end
  end

  def show; end

  def edit; end

  def update
    if @gift_item.update(gift_item_params_update)
      redirect_to gift_item_path(@gift_item)
    end
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
