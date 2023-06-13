require "test_helper"

class AssetLoansItemsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get asset_loans_items_index_url
    assert_response :success
  end

  test "should get show" do
    get asset_loans_items_show_url
    assert_response :success
  end

  test "should get edit" do
    get asset_loans_items_edit_url
    assert_response :success
  end
end
