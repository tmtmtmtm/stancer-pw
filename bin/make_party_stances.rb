#!/usr/bin/ruby

# Usage: ruby -Ilib bin/make_party_stances.rb > partystances.json

require 'json'
require 'stancer'
require 'colorize'

warn "Loading issues".yellow
issues  = JSON.parse(File.read('issues.json'))
warn "Loading motions".yellow
Stancer::Motion.configure(motions_file: 'motions.json')
warn "done".yellow

allstances = issues.map do |i|
  as = i['aspects'].map do |a| 
    a['motion'] = Stancer::Motion.find(a['motion_id']) or raise "No such motion"
    a
  end

  # i['stances'] = Stancer::Stance.new(as, 'party_id', lambda { |v| v['party_id'] == 'con' }).to_h
  i['stances'] = Stancer::Stance.new(as, 'party_id').to_h
  i.delete('aspects')
  i
end

puts JSON.pretty_generate(allstances.sort_by { |s| s['id'].sub(/^PW-/, '').to_i } )

