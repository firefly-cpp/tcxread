# tcxread -- A parser for TCX files written in Ruby

[![GitHub license](https://img.shields.io/github/license/firefly-cpp/tcxread.svg)](https://github.com/firefly-cpp/tcxread/blob/master/LICENSE)
![GitHub commit activity](https://img.shields.io/github/commit-activity/w/firefly-cpp/tcxread.jl.svg)

## About 📋

tcxread is a Ruby package designed to simplify the process of reading and processing .tcx files, commonly used by Garmin devices and other GPS-enabled fitness devices to store workout data.

## Installation 📦

```

```

## Basic run example 🚀

```ruby
require 'tcxread'

parser = TCXRead.new('2.tcx')
data = parser.parse
puts data.inspect
```

## Datasets

Datasets available and used in the examples on the following links: [DATASET1](http://iztok-jr-fister.eu/static/publications/Sport5.zip), [DATASET2](http://iztok-jr-fister.eu/static/css/datasets/Sport.zip), [DATASET3](https://github.com/firefly-cpp/tcx-test-files).

## Related packages/frameworks

[1] [tcxreader: Python reader/parser for Garmin's TCX file format.](https://github.com/alenrajsp/tcxreader)

[2] [sport-activities-features: A minimalistic toolbox for extracting features from sports activity files written in Python](https://github.com/firefly-cpp/sport-activities-features)

## License

This package is distributed under the MIT License. This license can be found online at <http://www.opensource.org/licenses/MIT>.

## Disclaimer

This framework is provided as-is, and there are no guarantees that it fits your purposes or that it is bug-free. Use it at your own risk!
