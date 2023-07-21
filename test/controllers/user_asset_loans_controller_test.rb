require "test_helper"

class UserAssetLoansControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get user_asset_loans_index_url
    assert_response :success
  end

  test "should get show" do
    get user_asset_loans_show_url
    assert_response :success
  end
end
