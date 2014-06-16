#!/usr/bin/ruby

# Usage: ruby -Ilib bin/make_party_stances.rb > partystances.yaml

require 'json'
require 'stancer'
require 'parallel'

issues = JSON.parse(File.read('issues.json'))

allstances = Parallel.map(issues, :in_threads => 5) do |i|
  warn "Generating stance on #{i['id']}"
  i['stances'] = Issue.new(i).aggregate_on(
    bloc:'party.id',
  ).scored_blocs
  i
end

puts JSON.pretty_generate(allstances.sort_by { |s| s['id'].sub(/^PW-/, '').to_i } )

