#!/usr/bin/ruby

# Usage: ruby bin/make_party_stances.rb > partystances.json

require 'json'
require 'stancer'

stancer = Stancer.new({
  sources: {
    issues:   'issues.json',  # includes indicators
    motions:  'motions.json', # includes votes
  },
  options: { 
    grouping: 'group',
    exclude:  'indicators',
  }
})

allstances = stancer.all_stances
puts JSON.pretty_generate(allstances.sort_by { |s| s['id'].sub(/^PW-/, '').to_i })

