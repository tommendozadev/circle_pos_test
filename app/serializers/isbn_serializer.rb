class IsbnSerializer
  def initialize(isbn13)
    @isbn13 = isbn13
  end

  def as_json(*)
    { data: { prefix: @isbn13[0, 12], check_digit: @isbn13[-1].to_i, isbn13: @isbn13 } }
  end

  def self.error(code:, message:, field: "isbn")
    { error: { code: code, message: message, field: field } }
  end
end
