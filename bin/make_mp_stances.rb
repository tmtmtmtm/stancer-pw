#!/usr/bin/ruby

# Usage: ruby -Ilib bin/make_mp_stances.rb > mpstances.json

require 'json'
require 'stancer'
require 'parallel'
require 'colorize'

issues  = JSON.parse(File.read('issues.json'))

allstances = []
errors = []

Parallel.each(issues, :in_threads => 10) do |i|
  begin
    # Do in blocks of 10
    issue = Issue.new(i)
    stances = issue.aspects.each_slice(10).map { |as|
      warn "Calculating #{i['text']} (#{i['id']}) for #{as.count} aspects"
      issue.aggregate_on(
        bloc:    'voter.id',
        motions: as.map { |a| a['motion_id'] },
      ).scored_blocs
    }.reduce(:merge)
    
    i['stances'] = Hash[stances.sort]
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
