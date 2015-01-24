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

  module Period
    DAILY = 1

    SiD = 24 * 60 * 60

    def determine_period(format)
      case format
      when /%d/ then DAILY
      else nil
      end
    end

    def next_start_period(now, period)
      case period
      when DAILY
          Time.mktime(now.year, now.month, now.mday) + SiD
      else
        nil
      end
    end
  end

  class TimeBasedLogDevice < LogDevice
    include Period

    DELAY_SECOND_TO_CLOSE_FILE = 5

    def initialize(log = nil, opt = {})
      @dev = @filename = nil
      @mutex = LogDeviceMutex.new
      if log.respond_to?(:write) and log.respond_to?(:close)
        @dev = log
      else
        @pattern = log
        @period = determine_period(@pattern)
        now = Time.now
        @filename = now.strftime(@pattern)
        @next_start_period = next_start_period(now, @period)
        @dev = open_logfile(@filename)
        @dev.sync = true
      end
    end

    def write(message)
      check_shift_log if @pattern
      @dev.write(message)
    rescue
      warn("log writing failed. #{$!}")
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
      if next_period?(Time.now)
        now = Time.now
        new_filename = now.strftime(@pattern)
        next_start_period = next_start_period(now, @period)
        shift_log_period(new_filename)
        @filename = new_filename
        @next_start_period = next_start_period
      end
    end

    def next_period?(now)
      if @period
        @next_start_period <= now
      else
        Time.now.strftime(@pattern) != @filename
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
