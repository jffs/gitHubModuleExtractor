require 'test_helper'

class GitHubControllerTest < ActionController::TestCase
  test "should get auth" do
    get :auth
    assert_response :success
  end

  test "should get repos" do
    get :repos
    assert_response :success
  end

  test "should get commits" do
    get :commits
    assert_response :success
  end

end
