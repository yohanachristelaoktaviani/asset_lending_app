require "test_helper"

class UserAssetReturnsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_asset_returns_index_url
    assert_response :success
  end

  test "should get show" do
    get user_asset_returns_show_url
    assert_response :success
  end
end
