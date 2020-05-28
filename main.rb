#!/usr/bin/env ruby

current_branch = `git symbolic-ref --short HEAD`.chomp
if current_branch != "master"
  if $?.exitstatus == 0
    puts "WARNING: You are on branch #{current_branch}, NOT master."
  else
    puts "WARNING: You are not on a branch"
  end
  puts
end

puts "Fetching merged branches..."
remote_branches= `git branch -r --merged`.
  split("\n").
  map(&:strip).
  reject {|b| b =~ /\/(#{current_branch}|master)/}

local_branches= `git branch --merged`.
  gsub(/^\* /, '').
  split("\n").
  map(&:strip).
  reject {|b| b =~ /(#{current_branch}|master)/}

if remote_branches.empty? && local_branches.empty?
  puts "No existing branches have been merged into #{current_branch}."
else
  puts "This will remove the following branches:"
  puts remote_branches.join("\n")
  puts local_branches.join("\n")
  puts "Proceed?"
  if gets =~ /^y/i
    remote_branches.each do |b|
      remote, branch = b.split(/\//)
      `git push #{remote} :#{branch}`
    end

    # Remove local branches
    `git branch -d #{local_branches.join(' ')}`
  else
    puts "No branches removed."
  end
end
