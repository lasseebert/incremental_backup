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

    # Tries to obtain lock
    def self.create task, &block
      lock = Lock.new task
      return false if lock.failed
      yield
      true
    ensure
      lock.release if lock
    end

    private

    # Release lock
    def release
      FileUtils.rm path
    end

    def path
      @path ||= File.join @task.settings.settings_path, LOCK_FILENAME.sub(/\{task_id\}/, @task.settins.task_id)
    end
  end
end
