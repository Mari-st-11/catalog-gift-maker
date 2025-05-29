class GiftListsController < ApplicationController
  def index
    @gift_lists = GiftList.includes(:user)
  end
end
