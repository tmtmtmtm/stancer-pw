#!/usr/bin/ruby

# Usage: ruby -Ilib bin/make_party_stances.rb > partystances.json

require 'json'
require 'stancer'
require 'colorize'

stancer = Stancer.new(
  motions_file: 'motions.json',
  issues_file:  'issues.json',
)

allstances = stancer.all_stances('party_id')

puts JSON.pretty_generate(allstances.sort_by { |s| s['id'].sub(/^PW-/, '').to_i } )

