# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "zayin"
  gem.homepage = "http://github.com/erochest/zayin"
  gem.license = "Apache2"
  gem.summary = %Q{A collection of Ruby utilities and Rake tasks.}
  gem.description = %Q{A collection of Ruby utilities and Rake tasks.}
  gem.email = "erochest@gmail.com"
  gem.authors = ["Eric Rochester"]
  gem.files = FileList['lib/**/*rb']
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
  test.rcov_opts << '--exclude "gems/*"'
end

task :default => :test

namespace :gem do
  desc 'This uploads the gem to rubygems.org.'
  task :cut do
    sh %{gem build zayin.gemspec}
  end

  desc 'This uploads the gem to rubygems.org.'
  task :push do
    build_out   = `gem build zayin.gemspec`

    build_lines = build_out.lines.map { |line| line.rstrip }
    build_file  = build_lines.select { |line| line.lstrip.start_with?('File: ') }.first
    gem_file    = build_file[6..-1]

    sh %{gem push #{gem_file}}
  end
end

