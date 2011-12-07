require 'fileutils'
require 'rake'
require 'rake/tasklib'
require 'vagrant'

module Zayin
  module Rake
    module Vagrant
      class PhpTasks < ::Rake::TaskLib
        def initialize
          yield self if block_given?
          @env ||= ::Vagrant::Environment.new
          define
        end

        def vm_ssh(cmd, output_dir)
          puts ">>> #{cmd}"
          @env.primary_vm.ssh.execute do |ssh|
            unless output_dir.nil?
              ssh.exec!("if [ ! -d #{output_dir} ]; then mkdir -p #{output_dir}; fi")
            end
            ssh.exec!(cmd) do |channel, stream, data|
              print data
              $stdout.flush
            end
          end
        end

        def define
          namespace :vagrant do
            namespace :php do
              desc <<-EOS
  Run phpunit on a PHP file.
    base_dir    The directory on the VM to run the phpunit in.
    phpunit_xml The phpunit.xml file relative to base_dir to configure the
                phpunit run.
    target      The class or PHP file relative to base_dir to run the tests on.
    coverage    The directory in the VM to put the HTML coverage reports into.
                EOS
              task :unit, [:base_dir,
                           :phpunit_xml,
                           :target,
                           :coverage] do |t, args|
                base_dir    = args[:base_dir] || '/vagrant'
                phpunit_xml = args[:phpunit_xml]
                target      = args[:target]
                coverage    = args[:coverage]

                opts = []
                opts << " -c #{phpunit_xml}" unless phpunit_xml.nil?
                opts << " --coverage-html #{coverage}" unless coverage.nil?
                opts << " #{target}" unless target.nil?

                cmd = "cd #{base_dir} && phpunit#{opts.join(' ')}"
                vm_ssh(cmd, coverage)
              end

              desc <<-EOS
  Run phpdoc in a directory.
    base_dir    The directory to run phpdoc from.
    output_dir  The output directory.
                EOS
              task :doc, [:base_dir, :output_dir] do |t, args|
                base_dir   = args[:base_dir]   || '/vagrant'
                output_dir = args[:output_dir] || '/vagrant/docs'

                cmd = "phpdoc -o HTML:frames:earthli -d #{base_dir} -t #{output_dir} " +
                  "-i tests/,dist/,build/"
                vm_ssh(cmd, output_dir)
              end

              desc <<-EOS
  Run PHP Mess Detector in a directory.
    base_dir    The directory to run phpmd from.
    output_dir  The output directory.
                EOS
              task :md, [:base_dir, :output_dir] do |t, args|
                base_dir   = args[:base_dir]   || '/vagrant'
                output_dir = args[:output_dir] || '/vagrant/phpmd'

                cmd = "phpmd #{base_dir} html codesize,design,naming,unusedcode " +
                  "--reportfile #{output_dir}/index.html"
                vm_ssh(cmd, output_dir)
              end

              desc <<-EOS
  Create PHP_Depend static code analysis report.
    base_dir    The directory to analyze.
    output_dir  The output directory.
                EOS
              task :depend, [:base_dir, :output_dir] do |t ,args|
                base_dir   = args[:base_dir]   || '/vagrant'
                output_dir = args[:output_dir] || '/vagrant/pdepend'

                cmd = "pdepend --jdepend-xml=#{output_dir}/jdepend.xml " +
                "--jdepend-chart=#{output_dir}/dependencies.svg " +
                "--overview-pyramid=#{output_dir}/overview-pyramid.svg " +
                "#{base_dir}"
                vm_ssh(cmd, output_dir)
              end

              desc <<-EOS
  Generate a PHP Copy/Paste Detection report.
    base_dir    The directory to analyze.
    output_dir  The output directory.
                EOS
              task :cpd, [:base_dir, :output_dir] do
                base_dir   = args[:base_dir]   || '/vagrant'
                output_dir = args[:output_dir] || '/vagrant/phpcpd'

                cmd = "phpcpd --log-pmd #{output_dir}/pmd-cpd.xml #{base_dir}"
                vm_ssh(cmd, output_dir)
              end

              desc <<-EOS
  Generate a PHP_CodeSniffer report for coding standards.
    base_dir    The directory to analyze.
    output_dir  The output directory.
    standard    The standard to check against (default is Zend).
                EOS
              task :cs, [:base_dir, :output_dir, :standard] do
                base_dir   = args[:base_dir]   || '/vagrant'
                output_dir = args[:output_dir] || '/vagrant/phpcs'
                standard   = args[:standard]   || 'Zend'

                cmd = "phpcs --report=checkstyle " +
                  "--extensions=php " +
                  "--ignore=*/tests/* " +
                  "--report-file=#{output_dir}/checkstyle.xml " +
                "--standard=#{standard} " +
                "#{base_dir}"
                vm_ssh(cmd, output_dir)
              end
            end
          end
        end
      end
    end
  end
end
