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

  def get_closed_issues(repo_name, start_time)
    i = 1
    closed_issues = []
    loop do
      issues = @client.list_issues(repo_name, options = {:sort => "updated", :state => "closed", :page => i})
      issues.each do | issue |
        return closed_issues if Time.parse(issue.updated_at) < start_time
        closed_issues << issue
      end
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
start_time = Chronic.parse('monday 0:00', :context => :past)

repo_name = ""

is = st.get_closed_issues(repo_name, start_time)
puts is.length

abort("Finished")

repos = st.recently_updated_repos(start_time)
puts "Number of repositories updated since last monday: #{repos.length}"
repos.each do |repo|
  puts "#{repo.name} - #{repo.updated_at}"
end