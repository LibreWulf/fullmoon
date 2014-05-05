# Weechat Fullmoon script
#
# This is a simple ruby script for weechat that can perform certain actions when
# there's a full moon. 
#
# Moon phase data provided by the Weather Underground API.
#
# Author: William Osler <{firstname}@{lastname}s.us>
#

def weechat_init
  Weechat.register("fullmoon", "William Osler <{firstname}@{lastname}s.us>",
                   "0.1", "MIT", "Performs certain actions during a full moon",
                   "shutdown", "")

  return WEECHAT_RC_OK
end

def shutdown
  Weechat.print("", "Fullmoon plugin shutting down.")
end

def checkmoon
  Weechat.print("Not implemented :(")
  return false
end
