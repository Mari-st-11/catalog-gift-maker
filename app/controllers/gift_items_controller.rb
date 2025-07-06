class GiftItemsController < ApplicationController
  before_action :set_gift_item, only: %i[ show edit update destroy ]
  before_action :set_gift_list, only: %i[ new ]

  def new
    @gift_item = GiftItem.new
  end

  def create

    @gift_item = current_user.gift_items.build(gift_item_params)

    if @gift_item.url.present?
    require "open-uri"
    require "nokogiri"

    ogp_info_fetched = false
    image_downloaded = false

    user_agent = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/555.36 (KHTML, like Gecko) Chrome/100.0.4896.127 Safari/555.36"

    # HTMLの内容を取得
    html = URI.open(@gift_item.url, "User-Agent" => user_agent, read_timeout: 60, open_timeout: 10).read
    doc = Nokogiri::HTML.parse(html)

    # OGP情報を取得
    @gift_item.name = doc.at('meta[property="og:title"]')&.[]("content") || doc.at("title")&.text
    @gift_item.description = doc.css('meta[property="og:description"], meta[name="description"]').first&.[]("content") || ""

    if @gift_item.name.present? || @gift_item.description.present?
      ogp_info_fetched = true
    end

    og_image_meta = doc.css('meta[property="og:image"], meta[name="og:image"]').first # meta nameの場合も取得
    if og_image_meta.present?
      image_url = og_image_meta["content"].to_s
      file = URI.open(image_url, read_timeout: 60, open_timeout: 10) # 画像をオブジェクトに
      @gift_item.image = file
      image_downloaded = true
    end

    else
      @gift_item.name = "商品名を入力してください"
      @gift_item.description = "説明文を入力してください"
      @gift_item.image = nil
    end

    if @gift_item.save
      if ogp_info_fetched && image_downloaded
        flash[:success] = 'ギフト情報を追加しました！'
      elsif ogp_info_fetched && !image_downloaded
        flash[:warning] = 'ギフト情報は取得できましたが、画像の取得に失敗しました。'
      elsif !ogp_info_fetched && !image_downloaded
        flash[:warning] = 'URLからギフト情報を自動で取得できませんでした。商品名・商品説明を入力してください。'
      end

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
    @gift_item.destroy!
    redirect_to gift_list_path(@gift_item.gift_list)
  end

  private

  def gift_item_params
    params.require(:gift_item).permit(:url, :name, :description, :image).merge(gift_list_uuid: params[:gift_list_uuid])
  end

  def gift_item_params_update
    params.require(:gift_item).permit(:url, :name, :description, :image, :image_cache)
  end

  def set_gift_item
    @gift_item = current_user.gift_items.find(params[:id])
  end

  def set_gift_list
    @gift_list = GiftList.find_by(uuid: params[:gift_list_uuid])
  end
end
