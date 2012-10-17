require 'test_helper'

class MeasureControllerTest < ActionController::TestCase
  test "should get hop" do
    get :hop
    assert_response :success
  end

end
