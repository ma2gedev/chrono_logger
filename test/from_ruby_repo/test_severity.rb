require 'helper'

class TestLoggerSeverity < Test::Unit::TestCase
  def test_enum
    logger_levels = ChronoLogger.constants
    levels = ["WARN", "UNKNOWN", "INFO", "FATAL", "DEBUG", "ERROR"]
    ChronoLogger::Severity.constants.each do |level|
      assert(levels.include?(level.to_s))
      assert(logger_levels.include?(level))
    end
    assert_equal(levels.size, ChronoLogger::Severity.constants.size)
  end
end
