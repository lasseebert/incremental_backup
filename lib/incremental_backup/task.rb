require 'logger'

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
        complete_path = File.join(settings.remote_path, schedule.to_s, timestamp)
        login = "#{settings.remote_user}@#{settings.remote_server}"
        rsync_path = "#{login}:#{progress_path}"

        # Make complete folder
        `ssh -i #{settings.ssh_key_path} #{login} "[ -d #{complete_path} ] || mkdir -p #{complete_path}"`

        # Rsync
        #`rsync #{rsync_options} -e "ssh -i #{settings.ssh_key_path}" --link-dest=#{current_path} #{settings.local_path} #{rsync_path}`
        `rsync #{rsync_options} -e "ssh" --link-dest=#{current_path} #{settings.local_path} #{rsync_path}`
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

    # Find out which schedule to run
    def find_schedule
      :hourly
    end
  end
end
