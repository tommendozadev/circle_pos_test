require "test_helper"

class IsbnSerializerTest < ActiveSupport::TestCase
  test "success shape" do
    assert_equal(
      { data: { prefix: "978014300723", check_digit: 4, isbn13: "9780143007234" } },
      IsbnSerializer.new("9780143007234").as_json
    )
  end

  test "error shape" do
    assert_equal(
      { error: { code: "x", message: "y", field: "isbn" } },
      IsbnSerializer.error(code: "x", message: "y")
    )
  end
end
