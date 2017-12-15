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
    extract_elements_for_array f, :states, State
    extract_elements_for_array f, :symbols
    extract_elements_for_array f, :initials, State
    extract_elements_for_array f, :finals, State
    extract_transitions f
    process_errors
  end

  def analise_string(string)
    child_result = false
    initials.each do |initial|
      @open = string.split ''
      initial_node = Node.new @node_counter, nil, initial, nil
      child_result = process_node initial_node, 0
    end
    process_result
    child_result
  end

  def obtain_transitions(state)
    @transitions.select do |transition|
      transition.origin == state
    end
  end

  def obtain_symbol_transitions(state, symbol, accept_epsilon = true)
    @transitions.select do |transition|
      epsilon = transition.symbol == 'E' && accept_epsilon
      result = transition.origin == state
      result && (transition.symbol == symbol || epsilon)
    end
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
    transitions = obtain_symbol_transitions current_node.state, symbol
    return process_final current_node if !symbol && final?(current_node.state)
    transitions = [] if error? current_node
    child_result = false
    transitions.each do |transition|
      result = process_transition current_node, position, transition
      child_result ||= result
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

  def final?(state)
    @finals.include?(state)
  end

  def process_errors
    @states.each do |state|
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

  def extract_elements_for_array(file, attribute, class_name = String)
    file.gets.chomp.split(',').each do |element|
      element = class_name.new element if class_name != String
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