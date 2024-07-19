require_relative '../lib/tcxread'
require 'json'
require 'minitest/autorun'
require 'rubygems'

def test_total_distance_meters
    parser = TCXRead.new('2.tcx')
    data = parser.parse
    assert_equal data[:activities][0][:total_calories], 924
end
