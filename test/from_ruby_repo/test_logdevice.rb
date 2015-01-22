# coding: US-ASCII
require 'helper'
require 'tempfile'
require 'tmpdir'
require 'parallel'
require 'delorean'
require 'pry'

class TestLogDevice < Test::Unit::TestCase
  class LogExcnRaiser
    def write(*arg)
      raise 'disk is full'
    end

    def close
    end
  end

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

  def d(format, opt = {})
    ChronoLogger::TimeBasedLogDevice.new(format, opt)
  end

  def test_initialize
    logdev = d(STDERR)
    assert_equal(STDERR, logdev.dev)
    assert_nil(logdev.filename)
    assert_raises(TypeError) do
      d(nil)
    end
    #
    logdev = d(@format)
    begin
      assert(File.exist?(@filename))
      assert(logdev.dev.sync)
      assert_equal(@filename, logdev.filename)
      logdev.write('hello')
    ensure
      logdev.close
    end
    # create logfile whitch is already exist.
    logdev = d(@format)
    begin
      logdev.write('world')
      logfile = File.read(@filename)
      assert_equal(1, logfile.split(/\n/).size)
      assert_match(/^helloworld$/, logfile)
    ensure
      logdev.close
    end
  end

  def test_write
    r, w = IO.pipe
    logdev = d(w)
    logdev.write("msg2\n\n")
    IO.select([r], nil, nil, 0.1)
    w.close
    msg = r.read
    r.close
    assert_equal("msg2\n\n", msg)
    #
    logdev = d(LogExcnRaiser.new)
    class << (stderr = '')
      alias write <<
    end
    $stderr, stderr = stderr, $stderr
    begin
      assert_nothing_raised do
        logdev.write('hello')
      end
    ensure
      logdev.close
      $stderr, stderr = stderr, $stderr
    end
    assert_equal "log writing failed. disk is full\n", stderr
  end

  def test_close
    r, w = IO.pipe
    logdev = d(w)
    logdev.write("msg2\n\n")
    IO.select([r], nil, nil, 0.1)
    assert(!w.closed?)
    logdev.close
    assert(w.closed?)
    r.close
  end

  def test_shifting_age_in_multiprocess
    old_log = [@tempfile.path, '20150122'].join
    new_log = [@tempfile.path, '20150123'].join
    $stderr, stderr = StringIO.new, $stderr
    begin
      Delorean.time_travel_to '2015-01-22 23:59:59'
      logger = ChronoLogger.new(@format)
      Parallel.map(['a', 'b'], :in_processes => 2) do |letter|
        5000.times do
          logger.info letter * 5000
        end
      end
      assert_no_match(/log shifting failed/, $stderr.string)
      assert_no_match(/log writing failed/, $stderr.string)
      assert { File.exist?(old_log) }
      assert { File.exist?(new_log) }
    ensure
      $stderr, stderr = stderr, $stderr
      Delorean.back_to_the_present
      File.unlink(old_log)
      File.unlink(new_log)
    end
  end

  def test_shifting_midnight
    Dir.mktmpdir do |tmpdir|
      log = "log20140102"
      begin
        File.open(log, "w") {}
        File.utime(*[Time.mktime(2014, 1, 1, 23, 59, 59)]*2, log)

        Delorean.time_travel_to '2014-01-02 23:59:59'
        dev = ChronoLogger::TimeBasedLogDevice.new(File.join(tmpdir, "log%Y%m%d"))
        dev.write("#{Time.now} hello-1\n")

        Delorean.time_travel_to '2014-01-03 00:00:01'
        dev.write("#{Time.now} hello-2\n")
      ensure
        Delorean.back_to_the_present
        dev.close
      end

      old_log = File.join(tmpdir, log)
      cont = File.read(old_log)
      assert_match(/hello-1/, cont)
      assert_not_match(/hello-2/, cont)
      new_log = File.join(tmpdir, "log20140103")
      bug = '[GH-539]'
      assert { File.exist?(new_log) }
      assert_match(/hello-2/, File.read(new_log), bug)
    end
  end
end
