class NotificationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @notifications = current_user.notifications.includes(gift_item: :gift_list).order(created_at: :desc)
    @notifications.unread.each(&:mark_as_read!)
  end
end
