# -*- encoding: utf-8 -*-
# Calculates the approximate illumination of the moon given a date. Large
# portions of this code are "adapted" (stolen) from
# http://bazaar.launchpad.net/~keturn/py-moon-phase/trunk/view/head:/moon.py
#
# Author::    William Osler (mailto:{firstname}@{lastname}s.us)
# License::   MIT

require 'date'

module MoonPhase
  # Constants from moon.py
  # ---------------------------------------------------------------------------

  # JDN stands for Julian Day Number
  # Angles here are in degrees

  # 1980 January 0.0 in JDN
  # Python: XXX: DateTime(1980).jdn yields 2444239.5 -- which one is right?
  # Ruby: XXX: Date.new(1980).jd yields 2444240 -- now I'm really confused
  EPOCH = 2444238.5

  # Ecliptic longitude of the Sun at epoch 1980.0
  ECLIPTIC_LONGITUDE_EPOCH = 278.833540

  # Ecliptic longitude of the Sun at perigee
  ECLIPTIC_LONGITUDE_PERIGEE = 282.596403

  # Eccentricity of Earth's orbit
  ECCENTRICITY = 0.016718

  # Semi-major axis of Earth's orbit, in kilometers
  SUN_SMAXIS = 1.49585e8

  # Sun's angular size, in degrees, at semi-major axis distance
  SUN_ANGULAR_SIZE_SMAXIS = 0.533128

  ## Elements of the Moon's orbit, epoch 1980.0

  # Moon's mean longitude at the epoch
  MOON_MEAN_LONGITUDE_EPOCH = 64.975464
  # Mean longitude of the perigee at the epoch
  MOON_MEAN_PERIGEE_EPOCH = 349.383063

  # Mean longitude of the node at the epoch
  NODE_MEAN_LONGITUDE_EPOCH = 151.950429

  # Inclination of the Moon's orbit
  MOON_INCLINATION = 5.145396

  # Eccentricity of the Moon's orbit
  MOON_ECCENTRICITY = 0.054900

  # Moon's angular size at distance a from Earth
  MOON_ANGULAR_SIZE = 0.5181

  # Semi-mojor axis of the Moon's orbit, in kilometers
  MOON_SMAXIS = 384401.0
  # Parallax at a distance a from Earth
  MOON_PARALLAX = 0.9507

  # Synodic month (new Moon to new Moon), in days
  SYNODIC_MONTH = 29.53058868

  # Base date for E. W. Brown's numbered series of lunations (1923 January 16)
  LUNATIONS_BASE = 2423436.0

  ## Properties of the Earth
  EARTH_RADIUS = 6378.16

  # ---------------------------------------------------------------------------
  # End constants from moon.py

  # Helper functions
  def MoonPhase.fix_angle(angle)
    if angle > 360 then
      return angle - 360
    elsif angle < 0 then
      return angle + 360
    end
    return angle
  end

  def MoonPhase.to_rad(angle)
    return Math::PI * angle / 180
  end

  def MoonPhase.to_deg(angle)
    return 180 * angle / Math::PI
  end

  def MoonPhase.deg_sin(angle)
    return Math.sin(to_deg(angle))
  end

  def MoonPhase.deg_cos(angle)
    return Math.sin(to_deg(angle))
  end


  def MoonPhase.kepler(m, ecc)
    epsilon = 1e-6

    m = to_rad(m)
    e = m

    while true do
      delta = e - ecc * Math.sin(e) - m
      e = e - delta / (1.0 - ecc * Math.cos(e))

      if delta.abs <= epsilon then
        break
      end
    end

    return e
  end

  # Calculate illumination of moon. returns a float value in range [0,1]
  def MoonPhase.moon_illumination_for(phase_date)
    # Calculation of the Sun's position

    # date within the epoch
    day = phase_date.jd - EPOCH

    # Mean anomaly of the Sun
    n = fix_angle((360/365.2422) * day)
    # Convert from perigee coordinates to epoch 1980
    m = fix_angle(n + ECLIPTIC_LONGITUDE_EPOCH - ECLIPTIC_LONGITUDE_PERIGEE)

    # Solve Kepler's equation
    ec = kepler(m, ECCENTRICITY)
    ec = Math.sqrt((1 + ECCENTRICITY) / (1 - ECCENTRICITY)) * Math.tan(ec/2.0)
    # True anomaly
    ec = 2 * to_deg(Math.atan(ec))
    # Suns's geometric ecliptic longuitude
    lambda_sun = fix_angle(ec + ECLIPTIC_LONGITUDE_PERIGEE)

    ########
    #
    # Calculation of the Moon's position

    # Moon's mean longitude
    moon_longitude = fix_angle(13.1763966 * day + MOON_MEAN_LONGITUDE_EPOCH)

    # Moon's mean anomaly
    mm = fix_angle(moon_longitude - 0.1114041 * day - MOON_MEAN_PERIGEE_EPOCH)

    # Moon's ascending node mean longitude
    # MN = fix_angle(NODE_MEAN_LONGITUDE_EPOCH - 0.0529539 * day)

    evection = 1.2739 * Math.sin(to_rad(2*(moon_longitude - lambda_sun) - mm))

    # Annual equation
    annual_eq = 0.1858 * Math.sin(to_rad(m))

    # Correction term
    a3 = 0.37 * Math.sin(to_rad(m))

    mmp = mm + evection - annual_eq - a3

    # Correction for the equation of the centre
    mec = 6.2886 * Math.sin(to_rad(mmp))

    # Another correction term
    a4 = 0.214 * Math.sin(to_rad(2 * mmp))

    # Corrected longitude
    lp = moon_longitude + evection + mec - annual_eq + a4

    # Variation
    variation = 0.6583 * Math.sin(to_rad(2*(lp - lambda_sun)))

    # True longitude
    lpp = lp + variation

    # Calculation of the phase of the Moon

    # Age of the Moon, in degrees
    moon_age = lpp - lambda_sun

    # Phase of the Moon
    moon_phase = (1 - Math.cos(to_rad(moon_age))) / 2.0

    return moon_phase
  end
end
