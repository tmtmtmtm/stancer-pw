#!/usr/bin/ruby

# Usage: ruby -Ilib bin/make_mp_stances.rb > mpstances.json

require 'json'
require 'stancer'
require 'parallel'
require 'colorize'

issues = JSON.parse(File.read('issues.json'))
parties = JSON.parse(File.read('parties.json'))

allstances = []
errors = []

Parallel.each(issues, :in_threads => 10) do |i|
  begin
    stances = parties.map { |p|
      warn "Calculating #{i['text']} (#{i['id']}) for #{p['name']}"
      Aspect.new(
        bloc:'voter.id',
        filter: "party.id:#{p['id']}",
        issue: Issue.new(i),
      ).scored_blocs
    }.reduce(:merge)
    
    i['stances'] = stances
    allstances << i
  rescue => e
    msg = "PROBLEM with #{i['text']} (#{i['id']}) = #{e}"
    errors << msg
    warn "#{msg}.red"
  end
end

puts JSON.pretty_generate(allstances.sort_by { |s| s['id'].sub(/^PW-/, '').to_i } )

errors.each do |msg| 
  warn "#{msg}".yellow
end
