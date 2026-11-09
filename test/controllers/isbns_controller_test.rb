require "test_helper"

class IsbnsControllerTest < ActionDispatch::IntegrationTest
  test "shows the form" do
    get root_path
    assert_response :success
  end

  test "valid input returns the full ISBN" do
    post isbns_path, params: { isbn: "978014300723" }
    assert_response :success
    assert_includes response.body, "9780143007234"
  end

  test "invalid input returns 422 with a message" do
    post isbns_path, params: { isbn: "12345" }
    assert_response 422
    assert_includes response.body, "exactly 12 digits"
  end

  test "JSON API" do
    post isbns_path(format: :json), params: { isbn: "978014300723" }
    assert_equal "9780143007234", response.parsed_body["isbn13"]
  end
end
