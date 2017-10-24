# frozen_string_literal: true

require 'rspec'
require_relative 'automaton'

file = '2_thomp.txt'
string = 'bc'

describe 'Validate string' do
  it 'should validate if the string belongs to the language' do
    automaton = Automaton.new

    automaton.read_file(file)
    valid = automaton.analise_string(string)
    expect(valid).to be true
    expect(automaton.result).to be_an_instance_of Array
    automaton.result.each do |result|
      expect(result).to be_an_instance_of Array
      puts
      result.each do |element|
        expect(element).to be_an_instance_of Node
        transition = element.parent_transition
        next unless transition
        origin = transition.origin.name
        destination = transition.destination.name
        symbol = transition.symbol
        puts "#{origin} -> #{destination} with #{symbol}"
      end
    end
  end
end