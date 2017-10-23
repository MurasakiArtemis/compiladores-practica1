# frozen_string_literal: true

require_relative 'state'

# Class for handling the nodes
class Node
  include Comparable
  attr_reader :id, :parent_transition, :state, :parent

  def initialize(id, parent_transition, state, parent)
    @id = id
    @parent_transition = parent_transition
    @state = state
    @parent = parent
  end

  def <=>(other)
    id <=> other.id
  end
end