# Calculates the civil sunset for a given location and date. Credit to the
# algorithm found at http://williams.best.vwh.net/sunrise_sunset_algorithm.htm
#
# Author::    William Osler (mailto:{firstname}@{lastname}s.us)
# Copyright:: Copyright (C) William Osler
# License::   MIT

require 'date'

module Sunset

  # Get nautical sunset time for given date and latitude/longitude pair
  def Sunset.sunset_for(date, lat, long)
    day_of_year = date.yday

    # Longitude to hour value
    long_hour = long / 15.0
    approx_time = day_of_year + ((18 - long_hour) / 24.0)

    # Sun's mean anomoly
    sun_anom = (0.9856 * approx_time) - 3.289

    # Sun's true longitude
    sun_long = sun_anom + (1.916 * degree_sin(sun_anom)) +
      (0.020 * degree_sin(sun_anom * 2)) + 282.634

    if (sun_long > 360) then
      sun_long -= 360
    elsif (sun_long <= 0)
      sun_long += 360
    end

    # Sun's right ascension
    right_asc = degree_atan(0.91764 * degree_tan(sun_long))

    if (right_asc > 360) then
      right_asc -= 360
    elsif (right_asc <= 0)
      right_asc += 360
    end

    # Right ascenion to same quadrant as sun_long
    long_quad = (sun_long / 90.0).floor * 90
    asc_quad = (right_asc / 90.0).floor * 90
    right_asc = right_asc + (long_quad - asc_quad)

    # Right ascension to hours
    right_asc /= 15

    # Sun declination
    sun_dec_sin = 0.39782 * degree_sin(sun_long)
    sun_dec_cos = degree_cos(degree_asin(sun_dec_sin))

    # Sun local hour angle
    cos_hour_angle = (degree_cos(96) - (sun_dec_sin * degree_sin(lat))) /
      (sun_dec_cos * degree_cos(lat))

    if (cos_hour_angle < -1) then
      return false # Sun doesn't set on this date
    end

    hour_angle = degree_acos(cos_hour_angle) / 15

    # Local mean time
    local_set_time = hour_angle + right_asc - (0.06571 * approx_time) - 6.622

    if (local_set_time >= 24) then
      local_set_time -= 24
    elsif (local_set_time < 0)
      local_set_time += 24
    end

    hour = local_set_time.floor
    minute = (local_set_time - hour) * 60

    return DateTime.new(date.year, date.month, date.mday, hour, minute)
  end


  # The rest of these are really simple math that could be done inline, but I
  # didn't want to risk complicating the actual calculation with conversions.
  def Sunset.deg_to_rad(num)
    return Math::PI * num / 180
  end

  def Sunset.rad_to_deg(num)
    return 180 * num / Math::PI 
  end

  def Sunset.degree_sin(num)
    return Math.sin(deg_to_rad(num))
  end

  def Sunset.degree_cos(num)
    return Math.cos(deg_to_rad(num))
  end

  def Sunset.degree_tan(num)
    return Math.tan(deg_to_rad(num))
  end

  def Sunset.degree_asin(num)
    return rad_to_deg(Math.asin(num))
  end

  def Sunset.degree_acos(num)
    return rad_to_deg(Math.acos(num))
  end

  def Sunset.degree_atan(num)
    return rad_to_deg(Math.atan(num))
  end
end
