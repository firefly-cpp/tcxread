require_relative '../lib/tcxread'
require 'minitest/autorun'
require 'rubygems'

class TCXReadTest < Minitest::Test
  def setup
    # tests for file 2.tcx
    @data1 = TCXRead.new('test/2.tcx')

    # tests for file 15.tcx
    @data2 = TCXRead.new('test/15.tcx')
  end

  def test_total_calories
    assert_equal @data1.total_calories, 924
    assert_equal @data2.total_calories, 2010
  end

  def test_total_distance
      assert_equal @data1.total_distance_meters, 24732.34
      assert_equal @data2.total_distance_meters, 116366.98

  end

  def test_total_duration
      assert_equal @data1.total_time_seconds, 3876.0
      assert_equal @data2.total_time_seconds, 17250.0
  end

  def test_total_ascent
      assert_equal @data1.total_ascent, 452.5999946594238
      assert_equal @data2.total_ascent, 1404.400026500225
  end
end