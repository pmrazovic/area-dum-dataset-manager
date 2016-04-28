require 'test_helper'

class SectionConfigurationsControllerTest < ActionController::TestCase
  setup do
    @section_configuration = section_configurations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:section_configurations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create section_configuration" do
    assert_difference('SectionConfiguration.count') do
      post :create, section_configuration: {  }
    end

    assert_redirected_to section_configuration_path(assigns(:section_configuration))
  end

  test "should show section_configuration" do
    get :show, id: @section_configuration
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @section_configuration
    assert_response :success
  end

  test "should update section_configuration" do
    patch :update, id: @section_configuration, section_configuration: {  }
    assert_redirected_to section_configuration_path(assigns(:section_configuration))
  end

  test "should destroy section_configuration" do
    assert_difference('SectionConfiguration.count', -1) do
      delete :destroy, id: @section_configuration
    end

    assert_redirected_to section_configurations_path
  end
end
