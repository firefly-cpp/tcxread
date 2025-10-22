require_relative '../lib/tcxread'
require 'minitest/autorun'

class TCXReadTestParse < Minitest::Test
  def setup
    @data = TCXRead.parse(File.read('test/fixtures/2.tcx'))
  end

  def test_total_distance
    assert_equal @data.total_distance_meters, 24732.34
  end
end
