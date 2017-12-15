# frozen_string_literal: true

require 'rspec'
require_relative 'automaton'

describe 'CreateAutomaton' do
  it 'should create automaton from file' do
    automaton = Automaton.new

    automaton.read_file('specification.txt')

    expect(automaton.states).to match_array([State.new('A'), State.new('B'), State.new('C')])
    expect(automaton.symbols).to match_array(%w[a b c])
    expect(automaton.initials).to match_array([State.new('A')])
    expect(automaton.finals).to match_array([State.new('C')])
    expect(automaton.transitions).to include(Transition.new State.new('A'), 'a', State.new('B'))
    expect(automaton.transitions).to include(Transition.new State.new('B'), 'b', State.new('C'))
    automaton.transitions.each do |transition|
      expect(transition).to be_an_instance_of(Transition)
      expect(automaton.states).to include(transition.origin)
      expect(automaton.states).to include(transition.destination)
      expect(automaton.symbols).to include(transition.symbol)
    end
  end
end