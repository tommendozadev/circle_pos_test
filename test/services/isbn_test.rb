require "test_helper"

class IsbnTest < ActiveSupport::TestCase
  test "spec example" do
    assert_equal "9780143007234", Isbn.complete("978014300723")
  end

  test "known published ISBNs" do
    assert_equal "9780306406157", Isbn.complete("978030640615")
    assert_equal "9781861972712", Isbn.complete("978186197271")
  end

  test "check digit is 0 when sum is a multiple of 10" do
    assert_equal "9783291029370", Isbn.complete("978329102937")
    assert_equal "0000000000000", Isbn.complete("000000000000")
  end

  test "weights start at 1 on the left" do
    assert_equal 9, Isbn.check_digit("100000000000")
    assert_equal 7, Isbn.check_digit("010000000000")
  end

  test "output always satisfies the ISBN-13 validity rule" do
    srand(7)
    500.times do
      full = Isbn.complete(Array.new(12) { rand(10) }.join)
      total = full.chars.each_with_index.sum { |c, i| c.to_i * (i.even? ? 1 : 3) }
      assert_equal 0, total % 10
    end
  end

  test "rejects invalid input" do
    ["", "   ", "97801430072", "9780143007234", "978-0-14-300723",
     "97801430072X", "-97801430072", "９７８０１４３００７２３", 978014300723, nil].each do |bad|
      assert_raises(Isbn::InvalidInputError) { Isbn.complete(bad) }
    end
  end
end