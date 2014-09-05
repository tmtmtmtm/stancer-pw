#!/usr/bin/ruby

require 'json'
require 'stancer'
require 'colorize'
require 'fileutils'
require 'pathname'

stancer = Stancer.new(
  motions_file: 'motions.json',
  issues_file:  'issues.json',
  grouping:     'voter',
)

output_dir = 'stances'


output_path = Pathname(output_dir)
FileUtils.mkdir_p output_path

stancer.all_stances.each do |s|
  json = JSON.pretty_generate(s)
  outfile = output_path + "#{s['id']}.json"
  File.open(outfile, 'w') { |fh| fh.write(json) }
end
  

