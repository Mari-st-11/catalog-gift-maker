class GiftListDecorator < Draper::Decorator
  delegate_all
  # 切り出してみたけど使わないので後で消す
  def giftlist_title
    "#{object.recipient_name}さんへ贈る#{object.purpose.presence || 'ギフトリスト'}"
  end
end
