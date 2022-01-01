require 'helper'
require 'tempfile'
require 'tmpdir'
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

  def test_exception_on_shifting_log
    old_log = [@tempfile.path, '20220101'].join
    new_log = [@tempfile.path, '20220102'].join
    $stderr, stderr = StringIO.new, $stderr
    begin
      Delorean.time_travel_to '2022-01-01 23:59:59.990'
      logger = ChronoLogger.new(@format)
      old_logdev = logger.instance_variable_get('@logdev')
      def old_logdev.create_logfile(filename)
        raise 'override create_logfile method'
      end
      sleep 1 # waiting for shift log file

      logger.info 'shift log'

      assert_match(/log shifting failed\. override create_logfile method/, $stderr.string)
      assert { File.exist?(old_log) }
      assert { !File.exist?(new_log) }
    ensure
      $stderr, stderr = stderr, $stderr
      Delorean.back_to_the_present
      File.unlink(old_log)
    end
  end

  def test_rotation_per_second
    Dir.mktmpdir do |tmpdir|
      begin
        logger = ChronoLogger.new([tmpdir, '%Y%m%dT%H%M%S'].join)
        Delorean.time_travel_to '2014-01-01 23:59:50'
        logger.debug 'rotation'
        Delorean.time_travel_to '2014-01-01 23:59:51'
        logger.debug 'per second'

        assert { File.exist?([tmpdir, '20140101T235950'].join) }
        assert { File.exist?([tmpdir, '20140101T235951'].join) }
      ensure
        Delorean.back_to_the_present
      end
    end
  end

  def test_rotation_per_day_and_create_dir
    Dir.mktmpdir do |tmpdir|
      begin
        Delorean.time_travel_to '2015-08-01 23:59:50'
        logger = ChronoLogger.new([tmpdir, '/%Y/%m/%d/test.log'].join)
        logger.debug 'rotation'
        Delorean.time_travel_to '2015-08-02 00:00:01'
        logger.debug 'new dir'

        assert { File.exist?([tmpdir, '/2015/08/01/test.log'].join) }
        assert { File.exist?([tmpdir, '/2015/08/02/test.log'].join) }
      ensure
        Delorean.back_to_the_present
      end
    end
  end

  class PeriodTest
    include ChronoLogger::Period
  end

  def test_period
    period = PeriodTest.new
    # seconds not supported
    assert { period.determine_period('%d%S').nil? }
    assert { period.determine_period('%e%s').nil? }
    assert { period.determine_period('%j%c').nil? }
    assert { period.determine_period('%j%r').nil? }
    assert { period.determine_period('%j%X').nil? }
    assert { period.determine_period('%j%T').nil? }

    # minutes not supported
    assert { period.determine_period('%d%M').nil? }
    assert { period.determine_period('%e%R').nil? }

    # hours not supported
    assert { period.determine_period('%d%H').nil? }
    assert { period.determine_period('%e%k').nil? }
    assert { period.determine_period('%e%l').nil? }
    assert { period.determine_period('%e%I').nil? }

    # days
    assert { period.determine_period('%Y%m%d') == ChronoLogger::Period::DAILY }
    assert { period.determine_period('%Y%m%e') == ChronoLogger::Period::DAILY }
    assert { period.determine_period('%Y%j') == ChronoLogger::Period::DAILY }
    assert { period.determine_period('%D') == ChronoLogger::Period::DAILY }
    assert { period.determine_period('%F') == ChronoLogger::Period::DAILY }
    assert { period.determine_period('%v') == ChronoLogger::Period::DAILY }
    assert { period.determine_period('%x') == ChronoLogger::Period::DAILY }
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
