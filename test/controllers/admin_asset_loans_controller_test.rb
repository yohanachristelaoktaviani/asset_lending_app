require "test_helper"

class AdminAssetLoansControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_asset_loans_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_asset_loans_show_url
    assert_response :success
  end
end
