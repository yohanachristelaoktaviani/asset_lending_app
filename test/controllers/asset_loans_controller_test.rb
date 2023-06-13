require "test_helper"

class AssetLoansControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get asset_loans_index_url
    assert_response :success
  end

  test "should get show" do
    get asset_loans_show_url
    assert_response :success
  end

  test "should get edit" do
    get asset_loans_edit_url
    assert_response :success
  end
end
