# Class for handling states
class State
  include Comparable
  attr_reader :name

  def initialize(name)
    @name = name
  end

  def <=>(other)
    name <=> other.name
  end
end