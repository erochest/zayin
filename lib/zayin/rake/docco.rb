require 'pathname'
require 'rake'
require 'rake/task'

module Zayin
  module Rake
    # Defines a Rake task for generating documentation with Docco, which must
    # be on the $PATH.
    def self.docco(name, src_files, *args)
      args || args = []
      args.insert 0, name

      body = proc {
        src_files.each do |src|
          puts "docco #{src}"
          system %{docco #{src}}

          basename = File.basename(src, File.extname(src)) + '.html'
          tmp = File.join('docs', basename)

          parts = Pathname.new(src).each_filename.to_a
          parts.shift
          parts.insert 0, 'docs'
          parts[-1] = basename
          dest = File.join(*parts)

          if tmp == dest
            # If the tmp and dest are the same, then change dest's filename to
            # index.html and only copy it.
            dest = File.join(File.dirname(tmp), 'index.html')
            FileUtils.cp(tmp, dest, :verbose => true)
          else
            dirname = File.dirname(dest)
            FileUtils.mkdir_p(dirname)
            FileUtils.mv(tmp, dest, :verbose => true)
            FileUtils.cp('docs/docco.css', File.join(dirname, 'docco.css'),
                         :verbose => true)
          end
        end
      }

      Rake::Task.define_task(*args, &body)
    end
  end
end

