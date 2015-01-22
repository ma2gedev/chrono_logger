require "chrono_logger/version"
require 'logger'

class ChronoLogger < Logger
  def initialize(logdev)
    @progname = nil
    @level = DEBUG
    @default_formatter = Formatter.new
    @formatter = nil
    @logdev = nil
    if logdev
      @logdev = TimeBasedLogDevice.new(logdev)
    end
  end

  class TimeBasedLogDevice < LogDevice
    DELAY_SECOND_TO_CLOSE_FILE = 5

    def initialize(log = nil, opt = {})
      @dev = @filename = nil
      @mutex = LogDeviceMutex.new
      if log.respond_to?(:write) and log.respond_to?(:close)
        @dev = log
      else
        @pattern = log
        @filename = Time.now.strftime(@pattern)
        @dev = open_logfile(@filename)
        @dev.sync = true
      end
    end

    def write(message)
      if @pattern && @dev.respond_to?(:stat)
        begin
          check_shift_log
        rescue
          warn("log shifting failed. #{$!}")
        end
      end
      begin
        @dev.write(message)
      rescue
        warn("log writing failed. #{$!}")
      end
    end

    def close
      @dev.close rescue nil
    end

  private

    def open_logfile(filename)
      begin
        open(filename, (File::WRONLY | File::APPEND))
      rescue Errno::ENOENT
        create_logfile(filename)
      end
    end

    def create_logfile(filename)
      begin
        logdev = open(filename, (File::WRONLY | File::APPEND | File::CREAT | File::EXCL))
        logdev.sync = true
      rescue Errno::EEXIST
        # file is created by another process
        logdev = open_logfile(filename)
        logdev.sync = true
      end
      logdev
    end

    def check_shift_log
      unless Time.now.strftime(@pattern) == @filename
        new_filename = Time.now.strftime(@pattern)
        shift_log_period(new_filename)
        @filename = new_filename
      end
    end

    def shift_log_period(filename)
      begin
        @mutex.synchronize do
          tmp_dev = @dev
          @dev = create_logfile(filename)
          Thread.new(tmp_dev) do |tmp_dev|
            sleep DELAY_SECOND_TO_CLOSE_FILE
            tmp_dev.close rescue nil
          end
        end
      rescue Exception => ignored
        warn("log shifting failed. #{$!}")
      end
    end
  end
end
