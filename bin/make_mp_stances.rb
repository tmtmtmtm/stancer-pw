#!/usr/bin/ruby

# Usage: ruby -Ilib bin/make_mp_stances.rb > mpstances.json

require 'json'
require 'stancer'
require 'colorize'

issues  = JSON.parse(File.read('issues.json'))
stancer = Stancer.new(motions_file: 'motions.json')

allstances = issues.map do |i|
  warn "Processing issue #{i['id']}: #{i['text']}".green
  as = i['aspects'].map do |a| 
    a['motion'] = stancer.find_motion(a['motion_id']) or raise "No such motion"
    a
  end

  # i['stances'] = Stancer::Stance.new(as, 'voter', lambda { |v| v['voter']['id'] == 'andy_burnham' }).to_h
  i['stances'] = Stancer::Stance.new(as, 'voter').to_h
  i.delete('aspects')
  i
end

puts JSON.pretty_generate(allstances.sort_by { |s| s['id'].sub(/^PW-/, '').to_i } )

