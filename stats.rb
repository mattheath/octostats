#!/usr/bin/env ruby

require "time"
require "chronic"
require "octokit"
require "trollop"

class Stats

  def initialize(u, p, o)
    @client = Octokit::Client.new(:login => u, :password => p)
    @org = o
  end

  def recently_updated_repos(start_time)
    start_time = Time.parse(start_time) if start_time.is_a? String
    repos = @client.organization_repositories(@org)
    recently_updated = []
    repos.each do |repo|
      recently_updated << repo if Time.parse(repo.updated_at) > start_time
    end
    return recently_updated
  end

  def get_opened_issues(repo_name, start_time, end_time)
    open_issues = []

    # Get issues which are open, and were opened during the time period
    i = 1
    loop do
      issues = @client.list_issues(repo_name, options = {:sort => "updated", :state => "open", :page => i})
      #puts "#{i} #{issues.length}"
      issues.each do | issue |
        open_issues << issue if Time.parse(issue.created_at) > start_time and Time.parse(issue.created_at) < end_time
      end
      break if issues.length == 0
      i += 1
    end

    # Get issues which are closed, but which were opened during the time period
    i = 1
    loop do
      issues = @client.list_issues(repo_name, options = {:sort => "updated", :state => "closed", :page => i})
      #puts "#{i} #{issues.length}"
      issues.each do | issue |
        open_issues << issue if Time.parse(issue.created_at) > start_time and Time.parse(issue.created_at) < end_time
      end
      return open_issues if issues.length == 0
      i += 1
    end
  end

  def get_closed_issues(repo_name, start_time, end_time)
    i = 1
    closed_issues = []
    loop do
      issues = @client.list_issues(repo_name, options = {:sort => "updated", :state => "closed", :page => i})
      #puts "#{i} #{issues.length}"
      issues.each do | issue |
        closed_issues << issue if Time.parse(issue.closed_at) > start_time and Time.parse(issue.closed_at) < end_time
      end
      return closed_issues if issues.length == 0
      i += 1
    end
  end

end


opts = Trollop::options do
  opt :user, "GitHub username", :type => String, :short => "-u"
  opt :pass, "GitHub password", :type => String, :short => "-p"
  opt :org, "GitHub organization", :type => String, :short => "-o"
end

st = Stats.new(opts[:user], opts[:pass], opts[:org])

puts start_time = Chronic.parse('monday 0:00', :context => :past)
puts end_time = Chronic.parse('sunday 23:59', :context => :past)

repo_name = ""

is = st.get_closed_issues(repo_name, start_time, end_time)
is.each do |i|
  puts "#{i.number} #{i.title}"
end
puts "#{is.length} closed issues"
puts ""

is = st.get_opened_issues(repo_name, start_time, end_time)
is.each do |i|
  puts "#{i.number} #{i.title}"
end
puts "#{is.length} opened issues"
puts ""



abort("Finished")

repos = st.recently_updated_repos(start_time)
puts "Number of repositories updated since last monday: #{repos.length}"
repos.each do |repo|
  puts "#{repo.name} - #{repo.updated_at}"
end