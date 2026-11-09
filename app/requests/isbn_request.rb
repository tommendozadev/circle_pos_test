class IsbnRequest
  MAX_LENGTH = 64

  attr_reader :isbn, :error

  def initialize(isbn:)
    @isbn = isbn
    @error = nil
  end

  def valid?
    @error = validate
    @error.nil?
  end

  private

  def validate
    if isbn.nil?
      { code: "missing_parameter", message: "isbn is required" }
    elsif !isbn.is_a?(String)
      { code: "invalid_type",
        message: "isbn must be a string (numbers lose leading zeros), got #{json_type(isbn)}" }
    elsif isbn.length > MAX_LENGTH
      { code: "too_long", message: "isbn must be at most #{MAX_LENGTH} characters" }
    end
  end

  def json_type(value)
    case value
    when Integer, Float then "number"
    when Array then "array"
    when true, false then "boolean"
    else value.respond_to?(:keys) ? "object" : value.class.name
    end
  end
end
