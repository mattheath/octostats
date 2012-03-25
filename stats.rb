#!/usr/bin/env ruby

require "time"
require "chronic"
require "octokit"

class Stats

  def initialize(u, p, o)
    @client = Octokit::Client.new(:login => u, :password => p)
    @org = o
  end

  def recent_repos(start_time)
    start_time = Time.parse(start_time) if start_time.is_a? String
    repos = @client.organization_repositories(@org)
    recent = []
    repos.each do |repo|
      repo_updated = Time.parse(repo.updated_at)
      recent << repo if repo_updated > start_time
    end
    return recent
  end

end

st = Stats.new("user", "pass", "org")

repos = st.recent_repos(Chronic.parse('monday 0:00', :context => :past))
puts "Number of repos #{repos.length}"
repos.each do |repo|
  puts repo.name
end