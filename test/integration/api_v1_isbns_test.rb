require "test_helper"

class ApiV1IsbnsTest < ActionDispatch::IntegrationTest
  def post_json(body)
    post "/api/v1/isbns", params: body.to_json, headers: { "Content-Type" => "application/json" }
  end

  test "200 with the full ISBN" do
    post_json(isbn: "978014300723")
    assert_response :ok
    assert_equal(
      { "data" => { "prefix" => "978014300723", "check_digit" => 4, "isbn13" => "9780143007234" } },
      response.parsed_body
    )
  end

  test "400 when isbn is missing" do
    post_json({})
    assert_response :bad_request
    assert_equal "missing_parameter", response.parsed_body.dig("error", "code")
  end

  test "400 when isbn is a JSON number" do
    post_json(isbn: 978014300723)
    assert_response :bad_request
    assert_equal "invalid_type", response.parsed_body.dig("error", "code")
  end

  test "422 when isbn breaks ISBN rules" do
    post_json(isbn: "978-0-14-300723")
    assert_response 422
    assert_equal "invalid_isbn", response.parsed_body.dig("error", "code")
    assert_match "digits 0-9 only", response.parsed_body.dig("error", "message")
  end
end
