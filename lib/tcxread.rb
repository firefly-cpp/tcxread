require "nokogiri"

# The `TCXRead` class processes and analyzes data from a TCX (Training Center XML) file.
# It extracts key metrics such as distance, time, calories, ascent/descent, altitude, heart rate,
# power (watts), cadence, and speed from the activities recorded in the TCX file.
#
# Reference (see also):
# I. Jr. Fister, L. Lukač, A. Rajšp, I. Fister, L. Pečnik, and D. Fister,
# "A minimalistic toolbox for extracting features from sport activity files,"
# 2021 IEEE 25th International Conference on Intelligent Engineering Systems (INES), 2021,
# pp. 121-126, doi: 10.1109/INES52918.2021.9512927.
class TCXRead
  # @!attribute [r] total_distance_meters
  #   @return [Float] The total distance covered in meters.
  # @!attribute [r] total_time_seconds
  #   @return [Float] The total time of activities in seconds.
  # @!attribute [r] total_calories
  #   @return [Integer] The total calories burned.
  # @!attribute [r] total_ascent
  #   @return [Float] The total ascent in meters.
  # @!attribute [r] total_descent
  #   @return [Float] The total descent in meters.
  # @!attribute [r] max_altitude
  #   @return [Float] The maximum altitude reached in meters.
  # @!attribute [r] average_heart_rate
  #   @return [Float] The average heart rate in beats per minute.
  # @!attribute [r] max_watts
  #   @return [String, Float] The maximum power output in watts, or 'NA' if unavailable.
  # @!attribute [r] average_watts
  #   @return [String, Float] The average power output in watts, or 'NA' if unavailable.
  # @!attribute [r] average_cadence_all
  #   @return [Float] The average cadence in RPM.
  # @!attribute [r] average_cadence_biking
  #   @return [Float] The average cadence for the whole activity in RPM.
  # @!attribute [r] average_speed_all
  #   @return [Float] The average speed for the whole activity in meters per second.
  # @!attribute [r] average_speed_moving
  #   @return [Float] The average speed while moving in meters per second.

  attr_reader :total_distance_meters, :total_time_seconds, :total_calories,
              :total_ascent, :total_descent, :max_altitude, :average_heart_rate,
              :max_watts, :average_watts, :average_cadence_all, :average_cadence_biking,
              :average_speed_all, :average_speed_moving

  # Initializes the TCXRead object and parses the TCX file.
  # @param file_path [String] The file path of the TCX file to process.
  def initialize(file_path)
    @file_path = file_path
    @doc = Nokogiri::XML(File.open(file_path))
    @doc.root.add_namespace_definition('ns3', 'http://www.garmin.com/xmlschemas/ActivityExtension/v2')

    @total_distance_meters = 0
    @total_time_seconds = 0
    @total_calories = 0
    @total_ascent = 0
    @total_descent = 0
    @max_altitude = 0
    @average_heart_rate = 0
    @max_watts = 'NA'
    @average_watts = 'NA'
    @average_cadence_all = 0
    @average_cadence_biking = 0
    @average_speed_all = 0
    @average_speed_moving = 0

    parse
  end

  # Parses the TCX file and computes metrics for all activities.
  def parse
    activities = parse_activities
    return if activities.empty?

    @total_time_seconds = activities.sum { |activity| activity[:total_time_seconds] }
    @total_distance_meters = activities.sum { |activity| activity[:total_distance_meters] }
    @total_calories = activities.sum { |activity| activity[:total_calories] }

    @total_ascent, @total_descent, @max_altitude = calculate_ascent_descent_and_max_altitude_from_activities(activities)
    @average_heart_rate = calculate_average(:heart_rate, activities)
    @max_watts, @average_watts = calculate_watts_from_activities(activities)

    cadence_results = calculate_average_cadence_from_activities(activities)
    @average_cadence_all = cadence_results[:average_cadence_all]
    @average_cadence_biking = cadence_results[:average_cadence_biking]

    speed_results = calculate_average_speed_from_activities(activities)
    @average_speed_all = speed_results[:average_speed_all]
    @average_speed_moving = speed_results[:average_speed_moving]
  end

  private

  # Parses activities from the TCX file.
  # @return [Array<Hash>] An array of parsed activity data.
  def parse_activities
    @doc.xpath('//xmlns:Activities/xmlns:Activity').map do |activity|
      laps = activity.xpath('xmlns:Lap').map { |lap| parse_lap(lap) }

      {
        sport: activity.attr('Sport'),
        id: activity.xpath('xmlns:Id').text,
        laps: laps,
        total_time_seconds: laps.sum { |lap| lap[:total_time_seconds] },
        total_distance_meters: laps.sum { |lap| lap[:distance_meters] },
        total_calories: laps.sum { |lap| lap[:calories] },
        total_ascent: laps.sum { |lap| lap[:total_ascent] },
        total_descent: laps.sum { |lap| lap[:total_descent] },
        max_altitude: laps.map { |lap| lap[:max_altitude] }.max,
        average_heart_rate: calculate_average(:heart_rate, laps)
      }
    end
  end

  # Parses a single lap from the TCX file.
  # @param lap [Nokogiri::XML::Node] The lap node to parse.
  # @return [Hash] The parsed lap data.
  def parse_lap(lap)
    trackpoints = lap.xpath('xmlns:Track/xmlns:Trackpoint').map { |tp| parse_trackpoint(tp) }

    {
      start_time: lap.attr('StartTime'),
      total_time_seconds: lap.xpath('xmlns:TotalTimeSeconds').text.to_f,
      distance_meters: lap.xpath('xmlns:DistanceMeters').text.to_f,
      calories: lap.xpath('xmlns:Calories').text.to_i,
      total_ascent: calculate_ascent(trackpoints),
      total_descent: calculate_descent(trackpoints),
      max_altitude: trackpoints.map { |tp| tp[:altitude_meters] }.max || 0,
      trackpoints: trackpoints || []
    }
  end

  # Parses a single trackpoint from the TCX file.
  # @param trackpoint [Nokogiri::XML::Node] The trackpoint node to parse.
  # @return [Hash] The parsed trackpoint data.
  def parse_trackpoint(trackpoint)
    {
      time: trackpoint.xpath('xmlns:Time').text,
      altitude_meters: trackpoint.xpath('xmlns:AltitudeMeters').text.to_f,
      distance_meters: trackpoint.xpath('xmlns:DistanceMeters').text.to_f,
      heart_rate: trackpoint.xpath('xmlns:HeartRateBpm/xmlns:Value').text.to_i,
      cadence: trackpoint.xpath('xmlns:Cadence').text.to_i,
      watts: trackpoint.xpath('xmlns:Extensions/ns3:TPX/ns3:Watts').text.to_f,
      speed: trackpoint.xpath('xmlns:Extensions/ns3:TPX/ns3:Speed').text.to_f
    }
  end

  # Calculates total ascent from an array of trackpoints.
  # @param trackpoints [Array<Hash>] An array of trackpoint data.
  # @return [Float] The total ascent in meters.
  def calculate_ascent(trackpoints)
    previous_altitude = nil
    trackpoints.sum do |tp|
      altitude = tp[:altitude_meters]
      ascent = previous_altitude && altitude > previous_altitude ? altitude - previous_altitude : 0
      previous_altitude = altitude
      ascent
    end
  end

  # Calculates total descent from an array of trackpoints.
  # @param trackpoints [Array<Hash>] An array of trackpoint data.
  # @return [Float] The total descent in meters.
  def calculate_descent(trackpoints)
    previous_altitude = nil
    trackpoints.sum do |tp|
      altitude = tp[:altitude_meters]
      descent = previous_altitude && altitude < previous_altitude ? previous_altitude - altitude : 0
      previous_altitude = altitude
      descent
    end
  end

  # Calculates ascent, descent, and maximum altitude from activities.
  # @param activities [Array<Hash>] An array of activity data.
  # @return [Array<Float>] Total ascent, total descent, and maximum altitude.
  def calculate_ascent_descent_and_max_altitude_from_activities(activities)
    total_ascent = activities.sum { |activity| activity[:total_ascent] }
    total_descent = activities.sum { |activity| activity[:total_descent] }
    max_altitude = activities.map { |activity| activity[:max_altitude] }.max
    [total_ascent, total_descent, max_altitude]
  end

  # Calculates the average value of a metric across laps or activities.
  # @param metric [Symbol] The metric to average (e.g., :heart_rate).
  # @param laps_or_activities [Array<Hash>] An array of lap or activity data.
  # @return [Float] The average value of the metric.
  def calculate_average(metric, laps_or_activities)
    values = laps_or_activities.flat_map do |lap|
      next [] unless lap[:trackpoints]
      lap[:trackpoints].map { |tp| tp[metric] }
    end.compact

    values.any? ? values.sum.to_f / values.size : 0.0
  end

  # Calculates power metrics from activities.
  # @param activities [Array<Hash>] An array of activity data.
  # @return [Array<String, Float>] Maximum and average power output.
  def calculate_watts_from_activities(activities)
    watts = activities.flat_map do |activity|
      activity[:laps].flat_map do |lap|
        lap[:trackpoints]&.map { |tp| tp[:watts] } || []
      end
    end.compact

    if watts.any?
      max_watts = watts.max
      avg_watts = watts.sum.to_f / watts.size
    else
      max_watts = 'NA'
      avg_watts = 'NA'
    end

    [max_watts, avg_watts]
  end

  # Calculates average cadence metrics from activities.
  # @param activities [Array<Hash>] An array of activity data.
  # @return [Hash] Average cadence metrics for all activities and biking only.
  def calculate_average_cadence_from_activities(activities)
    cadences = activities.flat_map { |activity| activity[:laps].flat_map { |lap| lap[:trackpoints].map { |tp| tp[:cadence] } if lap[:trackpoints] } }.compact
    {
      average_cadence_all: cadences.any? ? cadences.sum.to_f / cadences.size : 0.0,
      average_cadence_biking: cadences.reject(&:zero?).any? ? cadences.reject(&:zero?).sum.to_f / cadences.reject(&:zero?).size : 0.0
    }
  end

  # Calculates average speed metrics from activities.
  # @param activities [Array<Hash>] An array of activity data.
  # @return [Hash] Average speed metrics for the whole activity and moving activities only.
  def calculate_average_speed_from_activities(activities)
    speeds = activities.flat_map { |activity| activity[:laps].flat_map { |lap| lap[:trackpoints].map { |tp| tp[:speed] } if lap[:trackpoints] } }.compact
    {
      average_speed_all: speeds.any? ? speeds.sum.to_f / speeds.size : 0.0,
      average_speed_moving: speeds.reject(&:zero?).any? ? speeds.reject(&:zero?).sum.to_f / speeds.reject(&:zero?).size : 0.0
    }
  end
end
