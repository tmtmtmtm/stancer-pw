#!/usr/bin/ruby

require 'json'
require 'stancer'

issues = JSON.parse(File.read('data.json'))
parties = JSON.parse(File.read('parties.json'))

issues.each do |i|
  parties.each do |p|
    warn "Calculating #{i['text']} (#{i['id']}) for #{p['name']}"
    aspect = Aspect.new(
      bloc:'voter.id',
      filter: "party.id:#{p['id']}",
      issue: Issue.new(i['id']),
    )
    puts JSON.pretty_generate(aspect.scored_blocs)
    # TODO merge them all
  end
end
