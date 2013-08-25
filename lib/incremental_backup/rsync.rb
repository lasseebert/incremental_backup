require 'pty'

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

      rsync_command = "rsync #{rsync_options} -e ssh #{local_path} #{remote_path}"
      if options[:max_download_speed] || options[:max_upload_speed]
        trickle = "trickle"
        trickle += " -d #{options[:max_download_speed]}" if options[:max_download_speed]
        trickle += " -u #{options[:max_upload_speed]}" if options[:max_upload_speed]
        rsync_command = "#{trickle} #{rsync_command}"
      end

      execute_shell logger, rsync_command

    end

    private

    def self.execute_shell(logger, command)
      logger.info command
      begin
        last_line = nil
        PTY.spawn(command) do |stdout, stdin, pid|
          begin
            stdout.each do |line|
              log_line = line.gsub(/\n/, '') rescue line
              logger.info log_line
              last_line = line
            end
          rescue Errno::EIO => e
            # Can't tell the difference between process being killed
            # or process ended because it was done
            unless last_line =~ /total size is/
              logger.error "Errno::EIO"
              logger.error e
              raise e
            end
          end
        end
      rescue PTY::ChildExited => e
        logger.error "PTY::ChildExited"
        logger.error e
        raise e
      end
    end

  end
end
