require 'open3'

module IncrementalBackup
  class Rsync
    def self.execute(logger, local_path, remote_path, options)

      # TODO: Only use long options
      rsync_options = {
        "-azprvP" => nil,
        "--delete" => nil,
        "--delete-excluded" => nil,
        "--modify-window" => '2',
        "--force" => nil,
        "--ignore-errors" => nil,
        "--stats" => nil
      }
      rsync_options["--exclude-from"] = options[:exclude_file] if options[:exclude_file]
      rsync_options["--link-dest"] = options[:link_dest] if options[:link_dest]

      rsync_options = rsync_options.map{|key, value| "#{key}#{value ? "=#{value}" : ''}" }.join(' ')

      execute_shell logger, "rsync #{rsync_options} -e ssh #{local_path} #{remote_path}"

    end

    private

    # Runs a shell command
    def self.execute_shell(logger, command)
      Open3::popen3(command) { |stdin, stdout, stderr|
        tmp_stdout = stdout.read.strip
        tmp_stderr = stderr.read.strip
        logger.info("#{command}\n#{tmp_stdout}") unless tmp_stdout.empty?
        logger.error("#{command}\n#{tmp_stderr}") unless tmp_stderr.empty?
      }
    end
  end
end
