# -*- encoding: utf-8 -*-
# Calculates the civil sunset for a given location and date. Credit to the
# algorithm found at
# http://users.electromagnetic.net/bu/astro/sunrise-set.php
#
# Author::    William Osler (mailto:{firstname}@{lastname}s.us)
# Copyright:: Copyright (C) William Osler
# License::   MIT

require 'date'

module Sunset

  # Get sunset time for given date and latitude/longitude pair
  def Sunset.sunset_for(date, lat, long)
    # This equation takes west longitude to be postive, contradicting the common notations
    long *= -1

    # Julian cycle
    n = ((date.jd - 2451545 - 0.0009) - (long / 360.0)).round

    #Approximate julian date of solar noon
    j = 2451545 + 0.0009 + (long / 360.0) + n

    # Mean solar anomaly
    m = (357.5291 + 0.98560028 * (j - 2451545)) % 360

    # Equation of center
    c = (1.9148 * degree_sin(m)) + (0.0200 * degree_sin(2 * m)) + (0.0003 * degree_sin(3 * m))

    # Ecliptical longitude of the sun
    λ = (m + 102.9372 + c + 180) % 360

    # Sun declination
    delta = degree_asin(degree_sin(λ) * degree_sin(23.45))

    # Hour angle
    h = degree_acos((degree_sin(-0.83) - degree_sin(lat) * degree_sin(delta)) /
                    (degree_cos(lat) * degree_cos(delta)))

    # Another approximation
    approxj = 2451545 + 0.0009 + ((h + long) / 360.0) + n

    jset = approxj + (0.0053 * degree_sin(m)) - (0.0069 * degree_sin(2 * λ))

    # Adjust for the fact that julian date is measured from 12pm
    jset += 0.5

    setDate = Date.jd(jset)
    sethr = (jset - jset.floor) * 24
    setmin = (sethr - sethr.floor) * 60

    return Time.utc(setDate.year, setDate.month, setDate.day, sethr.floor, setmin.floor).localtime
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
