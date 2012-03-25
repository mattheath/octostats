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


opts = Trollop::options do
  opt :user, "GitHub username", :type => String, :short => "-u"      # string -u
  opt :pass, "GitHub password", :type => String, :short => "-p"      # string -p
  opt :org, "GitHub organization", :type => String, :short => "-o"   # string -o
end

st = Stats.new(opts[:user], opts[:pass], opts[:org])

repos = st.recent_repos(Chronic.parse('monday 0:00', :context => :past))
puts "Number of repos #{repos.length}"
repos.each do |repo|
  puts repo.name
end