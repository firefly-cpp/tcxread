require 'tcxread'

data = TCXRead.new('23.tcx')

puts "Distance meters: #{data.total_distance_meters}, " \
     "Time seconds: #{data.total_time_seconds}, " \
     "Calories: #{data.total_calories}, " \
     "Total ascent: #{data.total_ascent}, " \
     "Total descent: #{data.total_descent}, " \
     "Max altitude: #{data.max_altitude}, " \
     "Average heart rate: #{data.average_heart_rate}, " \
     "Average watts: #{data.average_watts}, " \
     "Max watts: #{data.max_watts}, " \
     "Average speed: #{data.average_speed_all}, " \
     "Average speed (moving): #{data.average_speed_moving}, " \
     "Average cadence (moving): #{data.average_cadence_biking}, " \
     "Average cadence: #{data.average_cadence_all}"
