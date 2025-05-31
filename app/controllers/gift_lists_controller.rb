class GiftListsController < ApplicationController
  def index
    @gift_lists = GiftList.includes(:user)
  end

  def new
    @gift_lists = GiftList.new
  end
end
