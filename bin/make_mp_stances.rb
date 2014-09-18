#!/usr/bin/ruby

# Usage: ruby bin/make_mp_stances.rb > mpstances.json

require 'json'
require 'stancer'

stancer = Stancer.new({
  sources: {
    motions: 'motions.json',
    issues:  'issues.json',
  },
  options: { 
    grouping: 'voter',
    exclude:  'indicators',
  }
})

allstances = stancer.all_stances
puts JSON.pretty_generate(allstances.sort_by { |s| s['id'].sub(/^PW-/, '').to_i } )

