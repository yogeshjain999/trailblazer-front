require "test_helper"

class ViewsControllerTest < ActionDispatch::IntegrationTest
  test "should get main" do
    get views_main_url
    assert_response :success
  end
end
