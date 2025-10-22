require_relative '../lib/tcxread'
require 'minitest/autorun'

class TCXReadTestLoadOpenFile < Minitest::Test
  def setup
    @data = TCXRead.load_file(File.open('test/fixtures/2.tcx'))
  end

  def test_total_distance
    assert_equal @data.total_distance_meters, 24732.34
  end
end
