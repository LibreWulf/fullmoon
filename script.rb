# -*- encoding: utf-8 -*-
# Weechat Fullmoon script
#
# This is a simple ruby script for weechat that can perform certain actions when
# there's a full moon.
#
# Author::    William Osler (mailto:{firstname}@{lastname}s.us)
# License::   MIT

$script_name = "fullmoon"

$options = { latitude: '0', longitude: '0', moon_nick: "My2SpookyNick",
  moon_trigger: '0.995', action: 'does a thing', channels:
  "freenode.#foo,esper.#bar"}

def weechat_init
  Weechat.register($script_name, "William Osler <{firstname}@{lastname}s.us>",
                   "0.1", "MIT", "Performs certain actions during a full moon",
                   "shutdown", "")

  # Initialize config
  $options.each do |key, value|
    if Weechat.config_is_set_plugin(key.to_s) then
      $options[key] = Weechat.config_get_plugin(key.to_s)
    else
      Weechat.config_set_plugin(key.to_s, value)
    end
  end

  # Listen for config changes
  Weechat.hook_config("plugins.var.ruby." + $script_name + ".*", "config_cb", "")

  # Our commands
  Weechat.hook_command("moon",
                       "Returns the percentage of the moon illuminated on a given date, or today if no date given",
                       "[date]",
                       "a valid ruby date like 2014-12-25",
                       "",
                       "moon_command_cb",
                       "")

  Weechat.hook_command("sunset",
                       "Returns the sunset time of a given date or today if not date given",
                       "[date]",
                       "a valid ruby date like 2014-12-25",
                       "",
                       "sunset_command_cb",
                       "")

  return Weechat::WEECHAT_RC_OK
end

def shutdown
  Weechat.print("", "Fullmoon plugin shutting down.")
  return Weechat::WEECHAT_RC_OK
end

def config_cb(data, option, value)
  # load options
  $options.each_key do |key|
    if Weechat.config_is_set_plugin(key.to_s) then
      $options[key] = Weechat.config_get_plugin(key.to_s)
    end
  end

  return Weechat::WEECHAT_RC_OK
end

def moon_command_cb(data, buffer, args)
  begin
    if args.nil? || args.empty?
      day = Date.today
    else
      datestr = args.split(" ")[0]
      day = Date.parse(datestr)
    end

    illum = MoonPhase.moon_illumination_for(day) * 100
    Weechat.print(buffer, "Illumination for #{day.iso8601}: #{illum}%")

  rescue ArgumentError => e
    if (e.message == "invalid date") then
      Weechat.print(buffer, "Invalid date.")
    else
      raise e
    end
  end

  return Weechat::WEECHAT_RC_OK
end

def sunset_command_cb(data, buffer, args)
  begin
    if args.nil? || args.empty?
      day = Date.today
    else
      datestr = args.split(" ")[0]
      day = Date.parse(datestr)
    end

    time = Sunset.sunset_for(day, $options[:latitude].to_i, $options[:longitude].to_i)
    Weechat.print(buffer, "Sunset for #{day.iso8601}: #{time.hour}:#{time.min}")
  rescue ArgumentError => e
    if (e.message == "invalid date") then
      Weechat.print(buffer, "Invalid date.")
    else
      raise e
    end
  end

  return Weechat::WEECHAT_RC_OK
end
