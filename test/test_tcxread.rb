require_relative '../lib/tcxread'
require 'minitest/autorun'

class TCXReadTest < Minitest::Test
  def setup
    @data = TCXRead.new('test/fixtures/2.tcx')
  end

  def test_total_calories
    assert_equal @data.total_calories, 924
  end

  def test_total_distance
    assert_equal @data.total_distance_meters, 24732.34
  end

  def test_total_duration
    assert_equal @data.total_time_seconds, 3876.0
  end

  def test_total_ascent
    assert_equal @data.total_ascent, 452.5999946594238
  end

  def test_NA_watts
    assert_equal @data.average_watts, 0.0
    assert_equal @data.max_watts, 0.0
  end

end
