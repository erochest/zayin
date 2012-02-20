require 'fileutils'
require 'rake'
require 'rake/tasklib'
require 'vagrant'

module Zayin
  module Rake
    # Defines a set of Rake tasks for working with Vagrant VMs.
    class VagrantTasks < ::Rake::TaskLib
      def initialize
        yield self if block_given?
        @env ||= Vagrant::Environment.new
        define
      end

      def vm_ssh(cmd)
        puts ">>> #{cmd}"
        @env.primary_vm.ssh.execute do |ssh|
          ssh.exec!(cmd) do |channel, stream, data|
            print data
            $stdout.flush
          end
        end
      end

      def define
        namespace :vagrant do
          desc 'vagrant up'
          task :up do
            puts 'vagrant up'
            @env.cli('up')
          end

          desc 'vagrant suspend'
          task :suspend do
            puts 'vagrant suspend'
            @env.cli('suspend')
          end

          desc 'Halts the VM.'
          task :halt do
            puts 'sudo halt'
            vm_ssh('sudo halt')
          end

          desc 'vagrant destroy'
          task :destroy do
            if @env.primary_vm.created?
              puts 'vagrant destroy'
              @env.cli('destroy')
            end
          end

          desc 'vagrant status'
          task :status do
            puts 'vagrant status'
            @env.cli('status')
          end

          namespace :chef do
            desc 'Dumps out the stacktrace from a Chef error.'
            task :st do
              raise "Must run `vagrant up`" unless @env.primary_vm.created?
              raise "Must be running!" unless @env.primary_vm.vm.running?
              puts "Getting chef stacktrace."
              vm_ssh("cat /tmp/vagrant-chef-1/chef-stacktrace.out")
            end

            desc 'Cleans up the cookbooks.'
            task :clean do
              FileUtils.rmtree('cookbooks', :verbose => true)
            end

            desc 'Clones the cookbooks given from git. URL is required. Cookbook directory and branch are optional.'
            task :cookbook, [:git_url, :cookbook_dir, :branch] do |t, args|
              url    = args[:git_url]
              cb_dir = args[:cookbook_dir]
              branch = args[:branch]
              raise 'You must specify a URL to clone.' if url.nil?

              basedir = File.dirname(cb_dir)
              Dir.mkdir(basedir) if basedir != '.' && !File.directory?(basedir)

              params = []
              params << "--branch=#{branch}" unless branch.nil?
              params << url
              params << cb_dir unless cb_dir.nil?

              sh %{git clone #{params.join(' ')}}
            end
          end
        end
      end
    end
  end
end

