require 'fileutils'

module IncrementalBackup
  class Lock

    LOCK_FILENAME = 'lock_{task_id}'

    attr_accessor :failed

    # Should not be called from other places than Lock.create
    def initialize task
      @task = task

      if File.exists? path
        self.failed = true
      else
        FileUtils.touch path
      end
    end

    # Obtains lock, run block, release lock
    def self.create task, &block
      task.logger.info 'Obtaining lock...'

      lock = Lock.new task

      if lock.failed
        task.logger.info 'Lock can not be obtained. Exiting!'
        return
      end

      task.logger.info 'Obtained lock'

      begin
        yield
      ensure
        task.logger.info 'Releasing lock...'
        lock.release
        task.logger.info 'Released lock'
      end

      true
    end

    # Release lock
    def release
      FileUtils.rm path
    end

    private

    def path
      @path ||= File.join @task.settings.settings_path, LOCK_FILENAME.sub(/\{task_id\}/, @task.settings.task_id)
    end
  end
end
