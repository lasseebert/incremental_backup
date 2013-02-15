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
        unless schedule
          logger.info "No backup needed - exiting"
          return
        end

        logger.info "Starting #{schedule} backup to #{settings.remote_server}"

        # Paths and other options
        timestamp = Time.now.strftime('backup_%Y-%m-%d-T%H-%M-%S')
        current_path = File.join(settings.remote_path, 'current')
        progress_path = File.join(settings.remote_path, 'incomplete')
        complete_path = File.join(schedule_path(schedule), timestamp)
        login = "#{settings.remote_user}@#{settings.remote_server}"
        rsync_path = "#{login}:#{progress_path}"

        # Make schedule folder
        execute_ssh "mkdir --verbose --parents #{schedule_path schedule}"

        # Rsync
        Rsync.execute(logger, settings.local_path, rsync_path, {
          exclude_file: settings.exclude_file,
          link_dest: current_path
        })

        # shuffle backups around
        logger.info "Do the backup shuffle"
        execute_ssh [
          "mv --verbose            #{progress_path} #{complete_path}",
          "rm --verbose --force    #{current_path}",
          "ln --verbose --symbolic #{complete_path} #{current_path}",
        ]

        delete_old_backups schedule

        logger.info "#{schedule} backup done"
      end

    rescue Exception => exception
      logger.error exception.message
      logger.error exception.backtrace
    end

    def logger
      @logger ||= Logger.new(File.join(settings.settings_path, LOG_FILENAME), NUM_LOG_FILES)
    end

    private

    def schedule_path(schedule)
      File.join(settings.remote_path, schedule.to_s)
    end

    def delete_old_backups(schedule)
      backups = list_backup_dir schedule
      backups_to_keep = settings.send("#{schedule}_backups")
      backups.sort!
      backups_to_delete = backups - backups.last(backups_to_keep)
      if backups_to_delete.any?
        if backups_to_delete.length == 1
          logger.info "Deleting old backup #{backups_to_delete.first}"
        else
          logger.info "Deleting #{backups_to_delete.length} old backups"
        end
        execute_ssh(backups_to_delete.map { |path| "rm --force --recursive #{path}" })
      end
    end

    def list_backup_dir(schedule)
      logger.info "Listing backup dir #{schedule_path schedule}"
      execute_ssh("mkdir -p #{schedule_path schedule}")
      execute_ssh("find #{schedule_path schedule} -maxdepth 1 -mindepth 1").split("\n")
    end

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
      result = ""
      Net::SSH.start settings.remote_server, settings.remote_user do |ssh|
        commands.each do |command|
          was_error = false
          logger.info "ssh: #{command}"
          ssh.exec! command do |channel, stream, data|
            case stream
            when :stdout
              logger.info data
              result += "#{data}\n" unless data.empty?
            when :stderr
              logger.error data
              was_error = true
            end
          end
          throw "Exception during ssh, look in log file" if was_error
        end
      end
      result
    end

    # Find out which schedule to run
    def find_schedule
      hours = {
        hourly: 1,
        daily: 24,
        weekly: 7*24,
        monthly: 30*24,
        yearly: 365*24
      }

      now = DateTime.now
      [:yearly, :monthly, :weekly, :daily, :hourly].each do |schedule|
        list = list_backup_dir schedule
        date = list.map { |path| parse_backup_dir_name path, now.offset }.max
        return schedule if !date || (now - date) * 24 > hours[schedule]
      end

      nil
    end

    def parse_backup_dir_name(dir, offset)
      if dir =~ /(\d{4})-(\d{2})-(\d{2})-T(\d{2})-(\d{2})-(\d{2})$/
        DateTime.new($1.to_i, $2.to_i, $3.to_i, $4.to_i, $5.to_i, $6.to_i, offset)
      end
    end
  end
end
