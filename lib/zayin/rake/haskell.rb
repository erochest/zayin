require 'fileutils'
require 'rake'
require 'rake/tasklib'

module Zayin
  module Rake
    # Defines a set of Rake tasks for working with Haskell/Cabal projects.
    class HaskellTasks < ::Rake::TaskLib
      def initialize
        yield self if block_given?
        define
      end

      def define
        namespace :hs do
          # Cabal-related tasks.
          desc 'Configures the project for development.'
          task :config, [:target] do |t, args|
            target = args[:target] || 'development'
            flags = []
            flags << %w{-f development --enable-tests} if target == 'development'
            sh %{cabal configure #{flags.join(' ')}}
          end

          desc 'Cleans up everything.'
          task :clean do
            sh %{cabal clean}
          end

          desc 'Runs Haddock to generate documentation.'
          task :docs do
            sh %{cabal haddock}
          end

          desc 'Runs tests.'
          task :test => 'hs:build' do
            sh %{cabal test}
          end

          desc 'Builds the Haskell project.'
          task :build, [:args] do |t, args|
            params = []
            params << args[:args] unless args[:args].nil?
            sh %{cabal build}
          end

          desc 'Installs the project locally.'
          task :install do
            sh %{cabal install}
          end

          desc 'Checks the project.'
          task :check do
            sh %{cabal check}
          end

          desc 'Uploads the project to Hackage.'
          task :upload, [:username, :password] do |t, args|
            username = args[:target]
            password = args[:target]
            params = []
            params << "--username=#{username}" unless not username.nil?
            params << "--password=#{password}" unless not password.nil?
            sh %{cabal upload #{params.join(' ')}}
          end

          # Other tools.
          desc 'Generates the tags file.'
          task :tags do
            FileUtils.rm('tags', :verbose => true)
            hs_tags = `find . -name '*.hs' | xargs hothasktags`
            File.open('tags', 'w') { |f| f.write(hs_tags) }
          end

          desc 'Runs hlint.'
          task :lint do
            sh %{hlint src}
          end

          desc 'Strips out the extra comments and fluff from the binary.'
          task :strip, [:target] do |t, args|
            target = args[:target]
            raise 'You must specify a target.' if target.nil?
            sh %{strip -p --strip-unneeded --remove-section=.comment -o #{target} ./dist/build/#{target}/#{target}}
          end

          namespace :hpc do
            desc 'This builds the executable with -fhpc.'
            task :build => ['hs:clean', 'hs:config'] do
              Rake::Task['hs:build'].invoke('--ghc-option=-fhpc')
            end

            desc 'This runs the hpc report.'
            task :report, [:tix, :modules] do |t, args|
              target  = args[:tix]
              modules = args[:modules]
              raise 'TIX file must be supplied.' if target.nil?
              raise 'Modules must be supplied.' if modules.nil?
              sh %{hpc report #{target} #{modules}}
            end

            desc 'This runs hpc markup.'
            task :markup, [:tix, :modules] do |t, args|  
              target  = args[:tix]
              modules = args[:modules]
              raise 'TIX file must be supplied.' if target.nil?
              raise 'Modules must be supplied.' if modules.nil?
              sh %{hpc markup #{target} #{modules}}
            end
          end
        end
      end
    end
  end
end

