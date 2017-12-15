# frozen_string_literal: true

require_relative 'node'
require_relative 'transition'
require_relative 'state'
require_relative 'automaton'

class Converter

  def initialize(automaton)
    @automaton = automaton
    @pending = []
    @processed = []
    @transitions = []
    @finals = []
    @current_state = 'A'
  end

  def convert_automaton
    @automaton.initials.each do |initial_state|
      first_state = cerradura_epsilon(initial_state)
      @pending.push first_state
      process_state until @pending.empty?
      return create_automaton
    end
  end

  private

  def print_array(array)
    array.each do |element|
      puts element.inspect
    end
    puts
  end

  def create_automaton
    process_finals
    process_result
    automaton = Automaton.new
    automaton.symbols = @automaton.symbols.clone
    automaton.initials = [@processed.first]
    automaton.states = @processed
    automaton.finals = @finals
    automaton.transitions = @transitions
    automaton
  end

  def process_result
    tmp = @processed.clone
    tmp.each do |state|
      @processed.map! do |element|
        if element.class == Array
          result = State.new(@current_state) if element == state
          result = element unless element == state
        else
          result = element
        end
        result
      end
      @finals.map! do |element|
        if element.class == Array
          result = State.new(@current_state) if element == state
          result = element unless element == state
        else
          result = element
        end
        result
      end
      @transitions.map! do |transition|
        if transition.origin.class == Array
          origin = State.new(@current_state) if transition.origin == state
          origin = transition.origin unless transition.origin == state
        else
          origin = transition.origin
        end
        if transition.destination.class == Array
          destination = State.new(@current_state) if transition.destination == state
          destination = transition.destination unless transition.destination == state
        else
          destination = transition.destination
        end
        Transition.new origin, transition.symbol, destination
      end
      @current_state = @current_state.next
    end
  end

  def process_finals
    @automaton.finals.each do |final_state|
      @processed.each do |state|
        @finals.push state if state.include? final_state
      end
    end
  end

  def process_state
    state = @pending.shift
    @automaton.symbols.each do |symbol|
      new_state = ir_a state, symbol
      transition = Transition.new state, symbol, new_state
      @transitions.push transition
      @processed.push state unless @processed.include? state
      next if @processed.include? new_state
      next if @pending.include? new_state
      @pending.push new_state
    end
  end

  def cerradura_epsilon(state_array)
    state_array = [state_array] if state_array.class == State
    result = []
    state_array.each do |state|
      result.push state
      transitions = @automaton.obtain_symbol_transitions state, 'E'
      transitions.each do |transition|
        result.concat cerradura_epsilon transition.destination
      end
    end
    result.uniq &:name
  end

  def mover(state_array, symbol)
    state_array = [state_array] if state_array.class == State
    result = []
    state_array.each do |state|
      states = []
      @automaton.obtain_symbol_transitions(state, symbol, false).each do |tran|
        states.push tran.destination
      end
      result.concat states
    end
    result
  end

  def ir_a(state_array, symbol)
    tmp = mover state_array, symbol
    cerradura_epsilon tmp
  end
end