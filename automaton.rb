# frozen_string_literal: true

require_relative 'node'
require_relative 'transition'
require_relative 'state'

# Class for handling the automaton, each one may have a different specification
class Automaton
  attr_accessor :states, :symbols, :initials, :finals, :transitions, :errors
  attr_accessor :open, :result, :node_counter

  def initialize
    @states = []
    @symbols = []
    @initials = []
    @finals = []
    @transitions = []
    @errors = []
    @open = []
    @result = []
    @node_counter = 0
  end

  def read_file(filename)
    f = File.new filename, 'r'
    extract_elements_for_array f, :states
    extract_elements_for_array f, :symbols
    extract_elements_for_array f, :initials
    extract_elements_for_array f, :finals
    extract_transitions f
    process_errors
  end

  def analise_string(string)
    child_result = false
    initials.each do |initial|
      @open = string.split ''
      initial_node = Node.new @node_counter, nil, State.new(initial), nil
      child_result = process_node initial_node, 0
    end
    process_result
    child_result
  end

  private

  def ascend_tree(element)
    return [] unless element.parent
    ascend_tree(element.parent).push element
  end

  def process_result
    results = []
    @result.each do |element|
      results.push ascend_tree element
    end
    @result = results
  end

  def process_node(current_node, position)
    symbol = @open.at(position)
    transitions = obtain_symbol_transitions current_node, symbol
    return process_final current_node if !symbol && final?(current_node.state)
    transitions = [] if error? current_node
    child_result = false
    transitions.each do |transition|
      child_result ||= process_transition current_node, position, transition
    end
    child_result
  end

  def process_transition(current_node, position, transition)
    position += 1 unless transition.symbol == 'E'
    next_node = transition_to(transition, current_node)
    process_node(next_node, position)
  end

  def process_final(current_node)
    @result.push current_node
    true
  end

  def transition_to(transition, current_node)
    @node_counter += 1
    Node.new @node_counter, transition, transition.destination, current_node
  end

  def obtain_symbol_transitions(node, symbol)
    @transitions.select do |transition|
      result = transition.origin == node.state
      result && (transition.symbol == symbol || transition.symbol == 'E')
    end
  end

  def obtain_transitions(state)
    @transitions.select do |transition|
      transition.origin == state
    end
  end

  def final?(state)
    @finals.include?(state.name)
  end

  def process_errors
    @states.each do |state|
      state = State.new state
      @errors.push state if determine_error state
    end
  end

  def error?(node)
    @errors.include? node.state
  end

  def determine_error(state)
    error = true
    obtain_transitions(state).each do |transition|
      error &&= transition.origin == transition.destination
    end
    error && !(final? state)
  end

  def extract_elements_for_array(file, attribute)
    file.gets.chomp.split(',').each do |element|
      send(attribute).push element
    end
  end

  def extract_transitions(file)
    file.each_line do |line|
      elements = line.chomp.split ','
      destination = State.new elements.pop
      symbol = elements.pop
      origin = State.new elements.pop
      @transitions.push Transition.new origin, symbol, destination
    end
  end
end