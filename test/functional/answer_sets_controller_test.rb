require 'test_helper'

class AnswerSetsControllerTest < ActionController::TestCase
  setup do
    @answer_set = answer_sets(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:answer_sets)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create answer_set" do
    assert_difference('AnswerSet.count') do
      post :create, answer_set: {  }
    end

    assert_redirected_to answer_set_path(assigns(:answer_set))
  end

  test "should show answer_set" do
    get :show, id: @answer_set
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @answer_set
    assert_response :success
  end

  test "should update answer_set" do
    put :update, id: @answer_set, answer_set: {  }
    assert_redirected_to answer_set_path(assigns(:answer_set))
  end

  test "should destroy answer_set" do
    assert_difference('AnswerSet.count', -1) do
      delete :destroy, id: @answer_set
    end

    assert_redirected_to answer_sets_path
  end
end
