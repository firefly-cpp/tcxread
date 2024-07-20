# tcxread -- A parser for TCX files written in Ruby

[![GitHub license](https://img.shields.io/github/license/firefly-cpp/tcxread.svg)](https://github.com/firefly-cpp/tcxread/blob/master/LICENSE)
![GitHub commit activity](https://img.shields.io/github/commit-activity/w/firefly-cpp/tcxread.jl.svg)

## About 📋

tcxread is a Ruby package designed to simplify the process of reading and processing .tcx files, commonly used by Garmin devices and other GPS-enabled fitness devices to store workout data.

## Installation 📦

```sh
$ gem install ast-tdl
```

## Basic run example 🚀

```ruby
require 'tcxread'

data = TCXRead.new('2.tcx')

puts "Distance meters: #{data.total_distance_meters}, " \
     "Time seconds: #{data.total_time_seconds}, " \
     "Calories: #{data.total_calories}, " \
     "Total ascent: #{data.total_ascent}, " \
     "Total descent: #{data.total_descent}, " \
     "Max altitude: #{data.max_altitude}, " \
     "Average heart rate: #{data.average_heart_rate}"
```

## Datasets

Datasets available and used in the examples on the following links: [DATASET1](http://iztok-jr-fister.eu/static/publications/Sport5.zip), [DATASET2](http://iztok-jr-fister.eu/static/css/datasets/Sport.zip), [DATASET3](https://github.com/firefly-cpp/tcx-test-files).

## Further read

[1] [Awesome Computational Intelligence in Sports](https://github.com/firefly-cpp/awesome-computational-intelligence-in-sports)

## Related packages/frameworks

[1] [tcxreader: Python reader/parser for Garmin's TCX file format.](https://github.com/alenrajsp/tcxreader)

[2] [sport-activities-features: A minimalistic toolbox for extracting features from sports activity files written in Python](https://github.com/firefly-cpp/sport-activities-features)

[3] [TCXReader.jl: Julia package designed for parsing TCX files](https://github.com/firefly-cpp/TCXReader.jl)

[4] [TCXWriter: A Tiny Library for writing/creating TCX files on Arduino](https://github.com/firefly-cpp/tcxwriter)

## License

This package is distributed under the MIT License. This license can be found online at <http://www.opensource.org/licenses/MIT>.

## Disclaimer

This framework is provided as-is, and there are no guarantees that it fits your purposes or that it is bug-free. Use it at your own risk!
