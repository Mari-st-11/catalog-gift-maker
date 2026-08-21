require "test_helper"

class StaticPagesControllerTest < ActionDispatch::IntegrationTest
  test "トップページが表示できる" do
    get root_path
    assert_response :success
  end
end
