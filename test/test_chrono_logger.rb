require 'helper'

class TestChronoLogger < Test::Unit::TestCase
  def test_that_it_has_a_version_number
    refute_nil ::ChronoLogger::VERSION
  end
end
