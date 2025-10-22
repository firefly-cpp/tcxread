require_relative '../lib/tcxread'
require 'minitest/autorun'

class TCXReadTestWatts < Minitest::Test
  def setup
    @data_with_watts = TCXRead.new('test/fixtures/23.tcx')
  end

  def test_watts_present
    assert_equal @data_with_watts.average_watts, 226.8091263216472
    assert_equal @data_with_watts.max_watts, 587
  end
end
