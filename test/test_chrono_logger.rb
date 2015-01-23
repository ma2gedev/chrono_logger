require 'helper'
require 'tempfile'
require 'parallel'
require 'delorean'

class TestChronoLogger < Test::Unit::TestCase
  def setup
    @tempfile = Tempfile.new("logger")
    @tempfile.close
    @format = [@tempfile.path, '%Y%m%d'].join
    @filename = Time.now.strftime(@format)
    File.unlink(@tempfile.path)
  end

  def teardown
    @tempfile.close(true)
  end

  def test_that_it_has_a_version_number
    refute_nil ::ChronoLogger::VERSION
  end

  def test_shifting_age_in_multithreads
    confirm_daily_rotation(in_threads: 2)
  end

  def test_shifting_age_in_multiprocess
    confirm_daily_rotation(in_processes: 2)
  end

private

  def confirm_daily_rotation(option)
    old_log = [@tempfile.path, '20150122'].join
    new_log = [@tempfile.path, '20150123'].join
    $stderr, stderr = StringIO.new, $stderr
    begin
      Delorean.time_travel_to '2015-01-22 23:59:59.990'
      logger = ChronoLogger.new(@format)
      old_logdev = logger.instance_variable_get('@logdev').dev
      Parallel.map(['a', 'b'], option) do |letter|
        5000.times do
          logger.info letter * 5000
        end
      end
      assert_no_match(/log shifting failed/, $stderr.string)
      assert_no_match(/log writing failed/, $stderr.string)
      assert { !old_logdev.closed? }
      assert { File.exist?(old_log) }
      assert { File.exist?(new_log) }
      assert { File.read(old_log).count("\n") + File.read(new_log).count("\n") == 10000 }

      sleep ChronoLogger::TimeBasedLogDevice::DELAY_SECOND_TO_CLOSE_FILE + 1
      old_logdev.close if option[:in_processes]
      assert { old_logdev.closed? } # TODO: check in multiprocess
      assert { File.exist?(old_log) }
      assert { File.exist?(new_log) }
      assert { File.read(old_log).count("\n") + File.read(new_log).count("\n") == 10000 }
    ensure
      $stderr, stderr = stderr, $stderr
      Delorean.back_to_the_present
      File.unlink(old_log)
      File.unlink(new_log)
    end
  end
end
