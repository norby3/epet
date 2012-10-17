require 'test_helper'

class DogwalksControllerTest < ActionController::TestCase
  setup do
    @dogwalk = dogwalks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:dogwalks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create dogwalk" do
    assert_difference('Dogwalk.count') do
      post :create, dogwalk: @dogwalk.attributes
    end

    assert_redirected_to dogwalk_path(assigns(:dogwalk))
  end

  test "should show dogwalk" do
    get :show, id: @dogwalk
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @dogwalk
    assert_response :success
  end

  test "should update dogwalk" do
    put :update, id: @dogwalk, dogwalk: @dogwalk.attributes
    assert_redirected_to dogwalk_path(assigns(:dogwalk))
  end

  test "should destroy dogwalk" do
    assert_difference('Dogwalk.count', -1) do
      delete :destroy, id: @dogwalk
    end

    assert_redirected_to dogwalks_path
  end
end
