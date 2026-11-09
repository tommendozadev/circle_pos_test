require "test_helper"

class IsbnRequestTest < ActiveSupport::TestCase
  def error_for(value)
    req = IsbnRequest.new(isbn: value)
    assert_not req.valid?
    req.error
  end

  test "any string passes the shape check (ISBN rules belong to the service)" do
    assert IsbnRequest.new(isbn: "abc").valid?
  end

  test "missing isbn" do
    assert_equal "missing_parameter", error_for(nil)[:code]
  end

  test "wrong types" do
    assert_match(/got number/, error_for(978014300723)[:message])
    assert_match(/got array/, error_for(["978014300723"])[:message])
    assert_match(/got object/, error_for({ "a" => 1 })[:message])
    assert_match(/got boolean/, error_for(true)[:message])
  end

  test "too long" do
    assert_equal "too_long", error_for("9" * 65)[:code]
  end
end
