class GiftItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_gift_item, only: %i[ show edit update destroy ]
  before_action :set_gift_list, only: %i[ new create search ]

  def new
    return redirect_to gift_lists_path, alert: "対象のギフトリストが見つかりません" if @gift_list.nil?

    @gift_item = GiftItem.new
  end

  # 楽天/Yahoo!ショッピングを横断検索する(APIキー未設定・片方の障害時は空配列を返すのみ)
  def search
    return redirect_to gift_lists_path, alert: "対象のギフトリストが見つかりません" if @gift_list.nil?

    @keyword = params[:keyword].to_s
    @results = ProductSearch.call(@keyword)

    respond_to do |format|
      format.turbo_stream
      format.html { render partial: "search_results", locals: { results: @results, keyword: @keyword, gift_list: @gift_list } }
    end
  end

  def create
    return redirect_to gift_lists_path, alert: "対象のギフトリストが見つかりません" if @gift_list.nil?

    @gift_item = current_user.gift_items.build(gift_item_params)

    ogp_info_fetched = false
    image_downloaded = false

    if params[:image_url].present?
      # API検索結果から選択された商品
      @gift_item.source_type = :api_search
      @gift_item.description ||= ""
      ogp_info_fetched = true

      begin
        @gift_item.image = SafeHtmlFetcher.fetch_as_io(params[:image_url])
        image_downloaded = true
      rescue SafeHtmlFetcher::FetchError => e
        Rails.logger.warn("API result image fetch failed: #{e.message}")
      end
    elsif @gift_item.url.present?
      @gift_item.source_type = :url_ogp

      begin
        html = SafeHtmlFetcher.fetch(@gift_item.url)
        doc = Nokogiri::HTML.parse(html)

        # OGP情報を取得
        @gift_item.name = doc.at('meta[property="og:title"]')&.[]("content") || doc.at("title")&.text
        @gift_item.description = doc.css('meta[property="og:description"], meta[name="description"]').first&.[]("content") || ""
        ogp_info_fetched = @gift_item.name.present? || @gift_item.description.present?

        og_image_meta = doc.css('meta[property="og:image"], meta[name="og:image"]').first # meta nameの場合も取得
        if og_image_meta.present?
          @gift_item.image = SafeHtmlFetcher.fetch_as_io(og_image_meta["content"].to_s)
          image_downloaded = true
        end
      rescue SafeHtmlFetcher::FetchError => e
        Rails.logger.warn("OGP fetch failed for #{@gift_item.url}: #{e.message}")
      end

      unless ogp_info_fetched
        @gift_item.name = "商品名を入力してください"
        @gift_item.description = "説明文を入力してください"
      end
    else
      @gift_item.source_type = :manual
      @gift_item.name = "商品名を入力してください"
      @gift_item.description = "説明文を入力してください"
      @gift_item.image = nil
    end

    if @gift_item.save
      if ogp_info_fetched && image_downloaded
        flash[:success] = "ギフト情報を追加しました！"
      elsif ogp_info_fetched && !image_downloaded
        flash[:warning] = "ギフト情報は取得できましたが、画像の取得に失敗しました。"
      elsif !ogp_info_fetched && !image_downloaded
        flash[:warning] = "URLからギフト情報を自動で取得できませんでした。商品名・商品説明を入力してください。"
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
    params.require(:gift_item).permit(:url, :name, :description, :image, :price).merge(gift_list_uuid: @gift_list.uuid)
  end

  def gift_item_params_update
    params.require(:gift_item).permit(:url, :name, :description, :image, :image_cache)
  end

  def set_gift_item
    @gift_item = current_user.gift_items.find(params[:id])
  end

  # current_userが所有するgift_listに限定する。ここをスコープしないと、
  # 他人のgift_list_uuidを指定して勝手にギフトを追加できてしまう(IDOR)。
  def set_gift_list
    @gift_list = current_user.gift_lists.find_by(uuid: params[:gift_list_uuid])
  end
end
