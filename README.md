<h1 align="center">
     tcxread -- A parser for TCX files written in Ruby
</h1>

<p align="center">
     <a href="https://badge.fury.io/rb/tcxread">
          <img alt="Gem Version" src="https://badge.fury.io/rb/tcxread.svg">
     </a>
     <a href="https://github.com/firefly-cpp/tcxread/blob/master/LICENSE">
          <img alt="License" src="https://img.shields.io/github/license/firefly-cpp/tcxread.svg">
     </a>
     <a href=https://repology.org/project/ruby:tcxread/versions>
          <img alt="Packaging status" src="https://repology.org/badge/tiny-repos/ruby:tcxread.svg">
     </a>
     <img alt="GitHub commit activity" src="https://img.shields.io/github/commit-activity/w/firefly-cpp/tcxread.svg">
     <img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/firefly-cpp/tcxread">
</p>

<p align="center">
     <a href="#-installation">📦 Installation</a> •
     <a href="#-basic-run-example">🚀 Basic run example</a> •
     <a href="#-datasets">💾 Datasets</a> •
     <a href="#-further-read">📖 Further read</a> •
     <a href="#-related-packagesframeworks">🔗 Related packages/frameworks</a> •
     <a href="#-license">🔑 License</a>
</p>

tcxread is a Ruby package designed to simplify the process of reading and processing .tcx files, commonly used by Garmin devices and other GPS-enabled fitness devices to store workout data.

## 📦 Installation

```sh
$ gem install tcxread
```

## 🚀 Basic run example

```ruby
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

```

## 💾 Datasets

Datasets available and used in the examples on the following links: [DATASET1](http://iztok-jr-fister.eu/static/publications/Sport5.zip), [DATASET2](http://iztok-jr-fister.eu/static/css/datasets/Sport.zip), [DATASET3](https://github.com/firefly-cpp/tcx-test-files).

## 📖 Further read

[1] [Awesome Computational Intelligence in Sports](https://github.com/firefly-cpp/awesome-computational-intelligence-in-sports)

## 🔗 Related packages/frameworks

[1] [tcxreader: Python reader/parser for Garmin's TCX file format.](https://github.com/alenrajsp/tcxreader)

[2] [sport-activities-features: A minimalistic toolbox for extracting features from sports activity files written in Python](https://github.com/firefly-cpp/sport-activities-features)

[3] [TCXReader.jl: Julia package designed for parsing TCX files](https://github.com/firefly-cpp/TCXReader.jl)

[4] [TCXWriter: A Tiny Library for writing/creating TCX files on Arduino](https://github.com/firefly-cpp/tcxwriter)

## 🔑 License

This package is distributed under the MIT License. This license can be found online at <http://www.opensource.org/licenses/MIT>.

## Disclaimer

This framework is provided as-is, and there are no guarantees that it fits your purposes or that it is bug-free. Use it at your own risk!
