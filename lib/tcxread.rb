require "nokogiri"

class TCXRead
  attr_reader :total_distance_meters, :total_time_seconds, :total_calories,
              :total_ascent, :total_descent, :max_altitude, :average_heart_rate,
              :max_watts, :average_watts, :average_cadence_all, :average_cadence_biking,
              :average_speed_all, :average_speed_moving

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

  def parse
    activities = parse_activities
    if activities.any?
      @total_time_seconds = activities.sum { |activity| activity[:total_time_seconds] }
      @total_distance_meters = activities.sum { |activity| activity[:total_distance_meters] }
      @total_calories = activities.sum { |activity| activity[:total_calories] }
      @total_ascent, @total_descent, @max_altitude = calculate_ascent_descent_and_max_altitude_from_activities(activities)
      @average_heart_rate = calculate_average_heart_rate_from_activities(activities)
      @max_watts, @average_watts = calculate_watts_from_activities(activities)
      cadence_results = calculate_average_cadence_from_activities(activities)
      @average_cadence_all = cadence_results[:average_cadence_all]
      @average_cadence_biking = cadence_results[:average_cadence_biking]
      speed_results = calculate_average_speed_from_activities(activities)
      @average_speed_all = speed_results[:average_speed_all]
      @average_speed_moving = speed_results[:average_speed_moving]
    end

    { activities: activities }
  end

  private

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
          watts: trackpoint.xpath('xmlns:Extensions/ns3:TPX/ns3:Watts').text.to_f,
          speed: trackpoint.xpath('xmlns:Extensions/ns3:TPX/ns3:Speed').text.to_f
        }
      end
      tracks << trackpoints
    end
    tracks
  end

  def parse_position(trackpoint)
    position = trackpoint.at_xpath('xmlns:Position')
    return nil unless position

    {
      latitude: position.xpath('xmlns:LatitudeDegrees').text.to_f,
      longitude: position.xpath('xmlns:LongitudeDegrees').text.to_f
    }
  end

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

  def calculate_average_cadence_from_activities(activities)
    total_cadence_all = 0
    total_cadence_biking = 0
    cadence_count_all = 0
    cadence_count_biking = 0

    activities.each do |activity|
      activity[:laps].each do |lap|
        lap[:tracks].flatten.each do |trackpoint|
          cadence = trackpoint[:cadence]
          total_cadence_all += cadence
          cadence_count_all += 1

          if cadence > 0
            total_cadence_biking += cadence
            cadence_count_biking += 1
          end
        end
      end
    end

    average_cadence_all = cadence_count_all > 0 ? total_cadence_all.to_f / cadence_count_all : 0.0
    average_cadence_biking = cadence_count_biking > 0 ? total_cadence_biking.to_f / cadence_count_biking : 0.0

    {
      average_cadence_all: average_cadence_all,
      average_cadence_biking: average_cadence_biking
    }
  end

  # Calculates the average speed from the activities.
  #
  # @param activities [Array<Hash>] an array of activity hashes.
  # @return [Hash] a hash containing average speed including zeros and average speed while moving.
  def calculate_average_speed_from_activities(activities)
    total_speed_all = 0
    total_speed_moving = 0
    speed_count_all = 0
    speed_count_moving = 0

    activities.each do |activity|
      activity[:laps].each do |lap|
        lap[:tracks].flatten.each do |trackpoint|
          speed = trackpoint[:speed]

          if speed
            total_speed_all += speed
            speed_count_all += 1

            if speed > 0
              total_speed_moving += speed
              speed_count_moving += 1
            end
          end
        end
      end
    end

    average_speed_all = speed_count_all > 0 ? total_speed_all.to_f / speed_count_all : 0.0
    average_speed_moving = speed_count_moving > 0 ? total_speed_moving.to_f / speed_count_moving : 0.0

    {
      average_speed_all: average_speed_all,
      average_speed_moving: average_speed_moving
    }
  end
end
