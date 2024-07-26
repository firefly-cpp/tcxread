require "nokogiri"

# TCXRead is a class that parses TCX (Training Center XML) files to extract
# workout data such as activities, laps, tracks, trackpoints, and integral metrics.
class TCXRead
  attr_reader :total_distance_meters, :total_time_seconds, :total_calories,
              :total_ascent, :total_descent, :max_altitude, :average_heart_rate,
              :max_watts, :average_watts

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
    # use NA if no watts exist in the TCX file
    @max_watts = 'NA'
    @average_watts = 'NA'

    parse
  end

  # Parses the TCX file and extracts data.
  #
  # @return [Hash] a hash containing the parsed activities.
  def parse
    activities = parse_activities
    if activities.any?
      @total_time_seconds = activities.sum { |activity| activity[:total_time_seconds] }
      @total_distance_meters = activities.sum { |activity| activity[:total_distance_meters] }
      @total_calories = activities.sum { |activity| activity[:total_calories] }
      @total_ascent, @total_descent, @max_altitude = calculate_ascent_descent_and_max_altitude_from_activities(activities)
      @average_heart_rate = calculate_average_heart_rate_from_activities(activities)
      @max_watts, @average_watts = calculate_watts_from_activities(activities)
    end

    { activities: activities }
  end

  private

  # Parses the activities from the TCX file.
  #
  # @return [Array<Hash>] an array of hashes, each representing an activity.
  def parse_activities
    activities = []
    @doc.xpath('//xmlns:Activities/xmlns:Activity').each do |activity|
      laps = parse_laps(activity)
      total_time_seconds = laps.sum { |lap| lap[:total_time_seconds] }
      total_distance_meters = laps.sum { |lap| lap[:distance_meters] }
      total_calories = laps.sum { |lap| lap[:calories] }
      total_ascent, total_descent, max_altitude = calculate_ascent_descent_and_max_altitude(laps)
      average_heart_rate = calculate_average_heart_rate(laps)

      activities << {
        sport: activity.attr('Sport'),
        id: activity.xpath('xmlns:Id').text,
        laps: laps,
        total_time_seconds: total_time_seconds,
        total_distance_meters: total_distance_meters,
        total_calories: total_calories,
        total_ascent: total_ascent,
        total_descent: total_descent,
        max_altitude: max_altitude,
        average_heart_rate: average_heart_rate
      }
    end
    activities
  end

  # Parses the laps for a given activity.
  #
  # @param activity [Nokogiri::XML::Element] the activity element from the TCX file.
  # @return [Array<Hash>] an array of hashes, each representing a lap.
  def parse_laps(activity)
    laps = []
    activity.xpath('xmlns:Lap').each do |lap|
      laps << {
        start_time: lap.attr('StartTime'),
        total_time_seconds: lap.xpath('xmlns:TotalTimeSeconds').text.to_f,
        distance_meters: lap.xpath('xmlns:DistanceMeters').text.to_f,
        maximum_speed: lap.xpath('xmlns:MaximumSpeed').text.to_f,
        calories: lap.xpath('xmlns:Calories').text.to_i,
        average_heart_rate: lap.xpath('xmlns:AverageHeartRateBpm/xmlns:Value').text.to_i,
        maximum_heart_rate: lap.xpath('xmlns:MaximumHeartRateBpm/xmlns:Value').text.to_i,
        intensity: lap.xpath('xmlns:Intensity').text,
        cadence: lap.xpath('xmlns:Cadence').text.to_i,
        trigger_method: lap.xpath('xmlns:TriggerMethod').text,
        tracks: parse_tracks(lap)
      }
    end
    laps
  end

  # Parses the tracks for a given lap.
  #
  # @param lap [Nokogiri::XML::Element] the lap element from the TCX file.
  # @return [Array<Array<Hash>>] an array of arrays, each representing a track containing trackpoints.
  def parse_tracks(lap)
    tracks = []
    lap.xpath('xmlns:Track').each do |track|
      trackpoints = []
      track.xpath('xmlns:Trackpoint').each do |trackpoint|
        trackpoints << {
          time: trackpoint.xpath('xmlns:Time').text,
          position: parse_position(trackpoint),
          altitude_meters: trackpoint.xpath('xmlns:AltitudeMeters').text.to_f,
          distance_meters: trackpoint.xpath('xmlns:DistanceMeters').text.to_f,
          heart_rate: trackpoint.xpath('xmlns:HeartRateBpm/xmlns:Value').text.to_i,
          cadence: trackpoint.xpath('xmlns:Cadence').text.to_i,
          sensor_state: trackpoint.xpath('xmlns:SensorState').text,
          watts: trackpoint.xpath('xmlns:Extensions/ns3:TPX/ns3:Watts').text.to_f
        }
      end
      tracks << trackpoints
    end
    tracks
  end

  # Parses the position for a given trackpoint.
  #
  # @param trackpoint [Nokogiri::XML::Element] the trackpoint element from the TCX file.
  # @return [Hash, nil] a hash representing the position (latitude and longitude) or nil if no position is available.
  def parse_position(trackpoint)
    position = trackpoint.at_xpath('xmlns:Position')
    return nil unless position

    {
      latitude: position.xpath('xmlns:LatitudeDegrees').text.to_f,
      longitude: position.xpath('xmlns:LongitudeDegrees').text.to_f
    }
  end

  # Calculates the total ascent, total descent, and maximum altitude from the laps.
  #
  # @param laps [Array<Hash>] an array of lap hashes.
  # @return [Array<Float>] an array containing total ascent, total descent, and maximum altitude.
  def calculate_ascent_descent_and_max_altitude(laps)
    total_ascent = 0.0
    total_descent = 0.0
    max_altitude = -Float::INFINITY
    previous_altitude = nil

    laps.each do |lap|
      lap[:tracks].flatten.each do |trackpoint|
        altitude = trackpoint[:altitude_meters]
        max_altitude = altitude if altitude > max_altitude

        if previous_altitude
          altitude_change = altitude - previous_altitude
          if altitude_change > 0
            total_ascent += altitude_change
          elsif altitude_change < 0
            total_descent += altitude_change.abs
          end
        end

        previous_altitude = altitude
      end
    end

    [total_ascent, total_descent, max_altitude]
  end


  # Calculates the total ascent, total descent, and maximum altitude from the activities.
  #
  # @param activities [Array<Hash>] an array of activity hashes.
  # @return [Array<Float>] an array containing total ascent, total descent, and maximum altitude.
  def calculate_ascent_descent_and_max_altitude_from_activities(activities)
    total_ascent = 0.0
    total_descent = 0.0
    max_altitude = -Float::INFINITY

    activities.each do |activity|
      total_ascent += activity[:total_ascent]
      total_descent += activity[:total_descent]
      max_altitude = activity[:max_altitude] if activity[:max_altitude] > max_altitude
    end

    [total_ascent, total_descent, max_altitude]
  end

  # Calculates the average heart rate from the laps.
  #
  # @param laps [Array<Hash>] an array of lap hashes.
  # @return [Float] the average heart rate.
  def calculate_average_heart_rate(laps)
    total_heart_rate = 0
    heart_rate_count = 0

    laps.each do |lap|
      lap[:tracks].flatten.each do |trackpoint|
        heart_rate = trackpoint[:heart_rate]
        if heart_rate > 0
          total_heart_rate += heart_rate
          heart_rate_count += 1
        end
      end
    end

    heart_rate_count > 0 ? total_heart_rate.to_f / heart_rate_count : 0.0
  end

  # Calculates the average heart rate from the activities.
  #
  # @param activities [Array<Hash>] an array of activity hashes.
  # @return [Float] the average heart rate.
  def calculate_average_heart_rate_from_activities(activities)
    total_heart_rate = 0
    heart_rate_count = 0

    activities.each do |activity|
      activity[:laps].each do |lap|
        lap[:tracks].flatten.each do |trackpoint|
          heart_rate = trackpoint[:heart_rate]
          if heart_rate > 0
            total_heart_rate += heart_rate
            heart_rate_count += 1
          end
        end
      end
    end

    heart_rate_count > 0 ? total_heart_rate.to_f / heart_rate_count : 0.0
  end

  # Calculates the maximum and average watts from the activities.
  #
  # @param activities [Array<Hash>] an array of activity hashes.
  # @return [Array<Float, Float>] an array containing maximum watts and average watts. Returns 'NA' for both if no watts data is available.
  def calculate_watts_from_activities(activities)
    max_watts = 0
    total_watts = 0
    watts_count = 0

    activities.each do |activity|
      activity[:laps].each do |lap|
        lap[:tracks].flatten.each do |trackpoint|
          watts = trackpoint[:watts]
          if watts > 0
            total_watts += watts
            watts_count += 1
            max_watts = watts if watts > max_watts
          end
        end
      end
    end

    if watts_count > 0
      average_watts = total_watts.to_f / watts_count
      max_watts = max_watts
    else
      average_watts = 'NA'
      max_watts = 'NA'
    end

    [max_watts, average_watts]
  end
end
