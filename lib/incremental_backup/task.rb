require 'logger'
require 'open3'

module IncrementalBackup
  class Task

    LOG_FILENAME = 'log'
    NUM_LOG_FILES = 10

    attr_accessor :settings

    def initialize(&block)
      self.settings = TaskSettings.new
      yield settings
    end

    # Perform the backup
    def run

      # Validate - this will throw an exception if settings are not valid
      validate_settings

      # Run everything inside a lock, ensuring that only one instance of this
      # task is running.
      Lock.create(self) do
        schedule = find_schedule
        logger.info "Starting #{schedule} backup to #{settings.remote_server}"

        # Options for rsync
        rsync_options = {
          "-azprvP" => nil,
          "--delete" => nil,
          "--delete-excluded" => nil,
          "--modify-window" => '2',
          "--force" => nil,
          "--ignore-errors" => nil,
          "--stats" => nil
        }
        rsync_options["--exclude-from"] = settings.exclude_file if settings.exclude_file
        rsync_options = "-azprvP --delete --delete-excluded --modify-window=2 --force --ignore-errors --stats"

        timestamp = Time.now.strftime('backup_%Y-%m-%d-T%H-%M-%S')
        current_path = File.join(settings.remote_path, 'current')
        progress_path = File.join(settings.remote_path, 'incomplete')
        schedule_path = File.join(settings.remote_path, schedule.to_s)
        complete_path = File.join(schedule_path, timestamp)
        login = "#{settings.remote_user}@#{settings.remote_server}"
        rsync_path = "#{login}:#{progress_path}"

        # Make schedule folder
        execute "ssh #{login} \"[ -d #{schedule_path} ] || mkdir -p #{schedule_path}\""

        # Rsync
        execute "rsync #{rsync_options} -e \"ssh\" --link-dest=#{current_path} #{settings.local_path} #{rsync_path}"

        # shuffle backups around
        execute "ssh #{login} mv #{progress_path} #{complete_path}"
        execute "ssh #{login} rm -f #{current_path}"
        execute "ssh #{login} ln -s #{complete_path} #{current_path}"

        # Delete old backups
        ctime = 1
        execute "ssh #{login} \"find #{schedule_path} -maxdepth 1 -mindepth 1 -ctime #{ctime} -exec rm -fR {} \\;\""

      end

    rescue Exception => exception
      puts "Error:"
      puts exception.message
    end

    def logger
      @logger ||= Logger.new(File.join(settings.settings_path, LOG_FILENAME), NUM_LOG_FILES)
    end

    private

    def validate_settings
      unless settings.valid?
        logger.error "Invalid settings:"
        settings.errors.full_messages.each do |message|
          logger.error message
        end
        throw "Invalid settings. Check the log file"
      end
      logger.info "Settings validated"
    end

    # Runs a shell command
    def execute(command)
      Open3::popen3(command) { |stdin, stdout, stderr|
        tmp_stdout = stdout.read.strip
        tmp_stderr = stderr.read.strip
        logger.info("#{command}\n#{tmp_stdout}") unless tmp_stdout.empty?
        logger.error("#{command}\n#{tmp_stderr}") unless tmp_stderr.empty?
      }
    end

    # Find out which schedule to run
    def find_schedule
      :hourly
    end
  end
end
