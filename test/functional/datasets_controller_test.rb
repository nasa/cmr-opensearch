require 'test_helper'

class DatasetsControllerTest < ActionController::TestCase
  test "should get descriptor_document" do
    get :descriptor_document
    assert_response :success
  end

end
