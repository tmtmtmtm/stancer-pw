#!/usr/bin/ruby

# Usage: ruby -Ilib bin/make_mp_stances.rb > mpstances.json

require 'json'
require 'stancer'
require 'colorize'

stancer = Stancer.new(
  motions_file: 'motions.json',
  issues_file:  'issues.json',
  grouping:     'voter',
  exclude:      'aspects',
)

allstances = stancer.all_stances
puts JSON.pretty_generate(allstances.sort_by { |s| s['id'].sub(/^PW-/, '').to_i } )

