require 'octokit'
require 'yaml'
require 'erb'

info = YAML.load_file('./info.yml')

client = Octokit::Client.new(access_token: info['token'])
user = info['user']
today = Date.today
last_tuesday = today - (today.wday - 2) - 7

repos = info['repositories'].map do |repo|
  prs = client.pull_requests(repo, state: 'closed')
          .select{|pr| pr.user.login == user && pr.closed_at > last_tuesday.to_time}
          .map(&:title)

  { name: repo, changes: prs }
end

template = File.read('./template.md.erb')

File.open("output.md","w") do |text|
  text.puts ERB.new(template, nil, '%').result(binding)
 end
