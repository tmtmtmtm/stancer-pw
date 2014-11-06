#!/usr/bin/ruby

# Usage: ruby bin/make_party_stances.rb > partystances.json

require 'json'
require 'stancer'

stancer = Stancer.new({
  sources: {
    issues:   'issues.json',  # includes indicators
    motions:  'motions.json', # includes votes
  }
})

allstances = stancer.all_stances(
  group_by: 'group',
  exclude:  'indicators',
)
puts JSON.pretty_generate(allstances.sort_by { |s| s['id'].sub(/^PW-/, '').to_i })

