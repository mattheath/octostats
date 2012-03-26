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

end


opts = Trollop::options do
  opt :user, "GitHub username", :type => String, :short => "-u"
  opt :pass, "GitHub password", :type => String, :short => "-p"
  opt :org, "GitHub organization", :type => String, :short => "-o"
end

st = Stats.new(opts[:user], opts[:pass], opts[:org])

repos = st.recently_updated_repos(Chronic.parse('monday 0:00', :context => :past))
puts "Number of repositories updated since last monday: #{repos.length}"
repos.each do |repo|
  puts repo.name
end