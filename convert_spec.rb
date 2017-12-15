require 'rspec'
require_relative 'automaton'
require_relative 'converter'

file = '2_thomp.txt'
string = 'bc'

describe 'Converter' do

  it 'should convert a previously generated automaton' do

    automaton = Automaton.new

    automaton.read_file(file)
    converter = Converter.new automaton
    valid = automaton.analise_string(string)
    expect(valid).to be true

    new_automaton = converter.convert_automaton
    new_valid = new_automaton.analise_string(string)
    expect(new_valid).to be valid

    new_automaton.result.each do |result|
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