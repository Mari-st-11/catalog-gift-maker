require "test_helper"

class GiftListsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(name: "贈り主", email: "owner@example.com", password: "password123")
    @other_user = User.create!(name: "他人", email: "other@example.com", password: "password123")
    @gift_list = @user.gift_lists.create!(recipient_name: "お母さん")
  end

  test "indexは未ログインでもアクセスできる(登録・ログイン導線を見せるため)" do
    get gift_lists_path
    assert_response :success
  end

  test "indexはステータスごとに正しいバッジ文言を表示する" do
    sign_in @user

    shared_list = @user.gift_lists.create!(recipient_name: "友人", status: :shared)
    selected_list = @user.gift_lists.create!(recipient_name: "同僚", status: :selected)
    completed_list = @user.gift_lists.create!(recipient_name: "家族", status: :completed)

    get gift_lists_path

    assert_response :success
    assert_match "相手の選択待ち", response.body
    assert_match "贈りものが決まりました", response.body
    assert_match "プレゼント完了", response.body
  end

  test "未ログインでnewにアクセスするとログイン画面にリダイレクトされる" do
    get new_gift_list_path
    assert_redirected_to new_user_session_path
  end

  test "未ログインでcreateしようとするとログイン画面にリダイレクトされる(ギフトリストは作られない)" do
    assert_no_difference -> { GiftList.count } do
      post gift_lists_path, params: { gift_list: { recipient_name: "誰か" } }
    end
    assert_redirected_to new_user_session_path
  end

  test "ログインすれば自分のギフトリストを作成できる" do
    sign_in @user

    assert_difference -> { @user.gift_lists.count }, 1 do
      post gift_lists_path, params: { gift_list: { recipient_name: "お父さん", purpose: "誕生日" } }
    end
    created = @user.gift_lists.find_by!(recipient_name: "お父さん")
    assert_redirected_to new_gift_list_gift_item_path(created)
  end

  test "所有者本人は自分のギフトリストを閲覧・編集・削除できる" do
    sign_in @user

    get gift_list_path(@gift_list)
    assert_response :success

    patch gift_list_path(@gift_list), params: { gift_list: { recipient_name: "更新後の名前" } }
    assert_redirected_to gift_list_path(@gift_list)
    assert_equal "更新後の名前", @gift_list.reload.recipient_name

    assert_difference -> { GiftList.count }, -1 do
      delete gift_list_path(@gift_list)
    end
  end

  test "他人のギフトリストは閲覧できない" do
    sign_in @other_user
    get gift_list_path(@gift_list)
    assert_response :not_found
  end

  test "他人のギフトリストは編集できない" do
    sign_in @other_user
    patch gift_list_path(@gift_list), params: { gift_list: { recipient_name: "乗っ取り" } }
    assert_response :not_found
    assert_not_equal "乗っ取り", @gift_list.reload.recipient_name
  end

  test "他人のギフトリストは削除できない" do
    sign_in @other_user
    delete gift_list_path(@gift_list)
    assert_response :not_found
    assert GiftList.exists?(@gift_list.id), "他人のギフトリストが削除されてはいけない"
  end

  test "共有リンクの再発行は所有者本人のみでき、public_tokenが変わる" do
    sign_in @user
    old_token = @gift_list.public_token

    post regenerate_public_token_gift_list_path(@gift_list)

    assert_redirected_to gift_list_path(@gift_list)
    assert_not_equal old_token, @gift_list.reload.public_token
  end

  test "他人はギフトリストの共有リンクを再発行できない" do
    sign_in @other_user
    old_token = @gift_list.public_token

    post regenerate_public_token_gift_list_path(@gift_list)

    assert_response :not_found
    assert_equal old_token, @gift_list.reload.public_token
  end
end
