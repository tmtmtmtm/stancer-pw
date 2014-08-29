#!/usr/bin/ruby

# Usage: ruby -Ilib bin/compare_stance_files.rb oldfile newfile

# Ensure that all the weights in oldfile are the same as in newfile
# even if order etc is different
# NB: doesn't check for extra stuff in newfile

require 'json'

old_file = ARGV.first
new_file = ARGV.last

old = JSON.parse(File.read(old_file))
new = JSON.parse(File.read(new_file))

old.each do |i_old|
  unless i_new = new.find { |i| i['id'] == i_old['id'] } 
    warn "Issue #{i_old['id']} not in #{new_file}" 
    next
  end

  i_old['stances'].each do |bloc, stance_old|
    unless stance_new = i_new['stances'][bloc] 
      warn "Issue #{i_old['id']} @ #{bloc}: no stance in #{new_file}" 
      next
    end

    unless stance_old['weight'] == stance_new['weight'] 
      warn "Issue #{i_old['id']} @ #{bloc}: #{stance_old['weight']} vs #{stance_new['weight']}" 
      next
    end
  end
end

