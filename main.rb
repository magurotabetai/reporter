require 'octokit'
require 'yaml'
require 'erb'
require 'pp'

info = YAML.load_file('./info.yml')

client = Octokit::Client.new(access_token: info['token'])
user = info['user']
today = Date.today
last_tuesday = today - (today.wday - 2) - 7

repos = info['repositories'].map do |repo|
  prs = client.pull_requests(repo, state: 'closed')
          .select{ |pr| pr.user.login == user && pr.closed_at > last_tuesday.to_time }

  changes = prs.map{ |pr| { title: pr.title, url: pr.html_url} }

  { name: repo, changes: changes }
end

template = File.read('./template.md.erb')

File.open("output.md", "w") do |text|
  text.puts ERB.new(template, nil, '-').result(binding)
end
