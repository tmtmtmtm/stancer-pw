#!/usr/bin/ruby

require 'json'
require 'stancer'
require 'colorize'

issue_id = ARGV[0]
mp_id = ARGV[1]

warn "Loading issues".yellow
issues  = JSON.parse(File.read('issues.json'))
warn "Loading motions".yellow
Stancer::Motion.configure(motion_file: 'motions.json')
warn "done".yellow

i = issues.find { |i| i['id'] == issue_id }
i['aspects'].each do |a| 
  m = Stancer::Motion.find(a['motion_id']) 
  m['vote_events'].each do |ve|
    puts ve['start_date']
    v = ve['votes'].find { |v| v['voter']['id'] = mp_id }
    puts " => #{v['option']}"
  end
end

