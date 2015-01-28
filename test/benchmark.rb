require 'rubygems'
require 'ruby-prof'

require 'bundler/setup'
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'chrono_logger'
require 'logger'
require 'mono_logger'
require 'log4r'

require 'parallel'
require 'benchmark'

std_logger = ::Logger.new('_std_logger')
with_cronolog = ::Logger.new(IO.popen("/usr/local/Cellar/cronolog/1.6.2/sbin/cronolog _with_cronolog.%Y%m%d", "w"))
mono_logger = MonoLogger.new('_mono_logger')
mono_with_cronolog = MonoLogger.new(IO.popen("/usr/local/Cellar/cronolog/1.6.2/sbin/cronolog _mono_with_cronolog.%Y%m%d", "w"))
chrono_logger = ChronoLogger.new('_chrono_logger.%Y%m%d')
# how to use?
#log4r = Log4r::Logger.new('benchmark')
#        x.level = ::Log4r::WARN
#        x.add ::Log4r::IOOutputter.new(
#          'benchmark', sio,
#          :formatter => ::Log4r::PatternFormatter.new(
#            :pattern => "%.1l, [%d #\#{Process.pid}] %5l : %M\n",
#            :date_pattern => "%Y-%m-%dT%H:%M:%S.\#{Time.now.usec}"
#          )
#        )

COUNT = 100_000

#result = RubyProf.profile do
#  COUNT.times do
#    chrono_logger.info letter
#  end
#end
#printer = RubyProf::FlatPrinter.new(result)
#printer.print(STDOUT)
#return

Benchmark.bm(10) do |bm|
  bm.report('std_logger:') { COUNT.times {std_logger.info 'logged'} }
  bm.report('with_cronolog:') { COUNT.times {with_cronolog.info 'logged'} }
  bm.report('mono_logger:') { COUNT.times {mono_logger.info 'logged'} }
  bm.report('mono_with_logger:') { COUNT.times {mono_logger.info 'logged'} }
  bm.report('chrono_logger:') { COUNT.times {chrono_logger.info 'logged'} }
end

# multi processes
std_logger = ::Logger.new('_std_logger_process')
with_cronolog = ::Logger.new(IO.popen("/usr/local/Cellar/cronolog/1.6.2/sbin/cronolog _with_cronolog_process.%Y%m%d", "w"))
mono_logger = MonoLogger.new('_mono_logger_process')
mono_with_cronolog = MonoLogger.new(IO.popen("/usr/local/Cellar/cronolog/1.6.2/sbin/cronolog _mono_with_cronolog_process.%Y%m%d", "w"))
chrono_logger = ChronoLogger.new('_chrono_logger_process.%Y%m%d')
Benchmark.bm(10) do |bm|
  bm.report('std_logger:') do
    Parallel.map(['1 logged', '2 logged'], in_processes: 2) do |letter|
      COUNT.times do
        std_logger.info letter
      end
    end
  end
  bm.report('with_cronolog:') do
    Parallel.map(['1 logged', '2 logged'], in_processes: 2) do |letter|
      COUNT.times do
        with_cronolog.info letter
      end
    end
  end
  bm.report('mono_logger:') do
    Parallel.map(['1 logged', '2 logged'], in_processes: 2) do |letter|
      COUNT.times do
        mono_logger.info letter
      end
    end
  end
  bm.report('mono_with_cronolog:') do
    Parallel.map(['1 logged', '2 logged'], in_processes: 2) do |letter|
      COUNT.times do
        mono_with_cronolog.info letter
      end
    end
  end
  bm.report('chrono_logger:') do
    Parallel.map(['1 logged', '2 logged'], in_processes: 2) do |letter|
      COUNT.times do
        chrono_logger.info letter
      end
    end
  end
end

# multi threads
std_logger = ::Logger.new('_std_logger_thread')
with_cronolog = ::Logger.new(IO.popen("/usr/local/Cellar/cronolog/1.6.2/sbin/cronolog _with_cronolog_thread.%Y%m%d", "w"))
mono_logger = MonoLogger.new('_mono_logger_thread')
mono_with_cronolog = MonoLogger.new(IO.popen("/usr/local/Cellar/cronolog/1.6.2/sbin/cronolog _mono_with_cronolog_thread.%Y%m%d", "w"))
chrono_logger = ChronoLogger.new('_chrono_logger_thread.%Y%m%d')
Benchmark.bm(10) do |bm|
  bm.report('std_logger:') do
    Parallel.map(['1 logged', '2 logged'], in_threads: 2) do |letter|
      COUNT.times do
        std_logger.info letter
      end
    end
  end
  bm.report('with_cronolog:') do
    Parallel.map(['1 logged', '2 logged'], in_threads: 2) do |letter|
      COUNT.times do
        with_cronolog.info letter
      end
    end
  end
  bm.report('mono_logger:') do
    Parallel.map(['1 logged', '2 logged'], in_threads: 2) do |letter|
      COUNT.times do
        mono_logger.info letter
      end
    end
  end
  bm.report('mono_with_cronolog:') do
    Parallel.map(['1 logged', '2 logged'], in_threads: 2) do |letter|
      COUNT.times do
        mono_with_cronolog.info letter
      end
    end
  end
  bm.report('chrono_logger:') do
    Parallel.map(['1 logged', '2 logged'], in_threads: 2) do |letter|
      COUNT.times do
        chrono_logger.info letter
      end
    end
  end
end

