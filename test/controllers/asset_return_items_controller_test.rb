require "test_helper"

class AssetReturnItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get asset_return_items_index_url
    assert_response :success
  end

  test "should get show" do
    get asset_return_items_show_url
    assert_response :success
  end
end
