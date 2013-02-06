require 'logger'
require 'net/ssh'

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

        # Find the schedule to run
        schedule = find_schedule
        logger.info "Starting #{schedule} backup to #{settings.remote_server}"

        # Paths and other options
        timestamp = Time.now.strftime('backup_%Y-%m-%d-T%H-%M-%S')
        current_path = File.join(settings.remote_path, 'current')
        progress_path = File.join(settings.remote_path, 'incomplete')
        schedule_path = File.join(settings.remote_path, schedule.to_s)
        complete_path = File.join(schedule_path, timestamp)
        login = "#{settings.remote_user}@#{settings.remote_server}"
        rsync_path = "#{login}:#{progress_path}"

        # Make schedule folder
        execute_ssh "mkdir --verbose --parents #{schedule_path}"

        # Rsync
        Rsync.execute(logger, settings.local_path, rsync_path, {
          exclude_file: settings.exclude_file,
          link_dest: current_path
        })

        ctime = 1
        execute_ssh [
          # shuffle backups around
          "mv --verbose            #{progress_path} #{complete_path}",
          "rm --verbose --force    #{current_path}",
          "ln --verbose --symbolic #{complete_path} #{current_path}",

          # Delete old backups
          "find #{schedule_path} -maxdepth 1 -mindepth 1 -ctime #{ctime} -exec rm -fR {} \\;"
        ]

        logger.info 'Backup done'
      end

    rescue Exception => exception
      logger.error exception.message
      logger.error exception.backtrace
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

    # Runs one ore more commands remotely via ssh
    def execute_ssh(commands)
      commands = [commands] unless commands.is_a? Array
      Net::SSH.start settings.remote_server, settings.remote_user do |ssh|
        commands.each do |command|
          ssh.exec! command do |channel, stream, data|
            case stream
            when :stdout
              logger.info data
            when :stderr
              logger.error data
            end
          end
        end
      end
    end

    # Find out which schedule to run
    def find_schedule
      :hourly
    end
  end
end
