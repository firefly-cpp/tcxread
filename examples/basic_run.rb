require 'tcxread'

data = TCXRead.new('2.tcx')

puts "Distance meters: #{data.total_distance_meters}, " \
     "Time seconds: #{data.total_time_seconds}, " \
     "Calories: #{data.total_calories}, " \
     "Total ascent: #{data.total_ascent}, " \
     "Total descent: #{data.total_descent}, " \
     "Max altitude: #{data.max_altitude}, " \
     "Average heart rate: #{data.average_heart_rate}"

