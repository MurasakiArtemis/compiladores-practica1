# frozen_string_literal: true

require_relative 'node'

# Class for handling the production rules
class Transition
  include Comparable
  attr_accessor :origin, :symbol, :destination

  def initialize(origin, symbol, destination)
    @origin = origin
    @symbol = symbol
    @destination = destination
  end

  def <=>(other)
    result = origin <=> other.origin
    return result if result
    result = symbol <=> other.symbol
    return result if result
    result = destination <=> other.destination
    result if result
  end
end