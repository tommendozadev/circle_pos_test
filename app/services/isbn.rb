# frozen_string_literal: true

module Isbn
  class InvalidInputError < ArgumentError; end

  WEIGHTS = [1, 3].freeze
  PAYLOAD_PATTERN = /\A[0-9]{12}\z/.freeze

  module_function

  def complete(input)
    digits = normalize(input)
    digits + check_digit(digits).to_s
  end

  def check_digit(digits)
    sum = digits.each_char.with_index.sum { |char, i| char.to_i * WEIGHTS[i % 2] }
    (10 - (sum % 10)) % 10
  end

  def normalize(input)
    unless input.is_a?(String)
      raise InvalidInputError, "input must be a String of 12 digits, got #{input.class}"
    end

    candidate = input.strip
    raise InvalidInputError, "input is empty; expected 12 digits" if candidate.empty?

    unless candidate.match?(/\A[0-9]+\z/)
      raise InvalidInputError,
            "input must contain digits 0-9 only (no hyphens, spaces or letters), got #{input.inspect}"
    end

    unless candidate.match?(PAYLOAD_PATTERN)
      raise InvalidInputError, "input must be exactly 12 digits, got #{candidate.length}"
    end

    candidate
  end
end
