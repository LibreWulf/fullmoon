Weechat Fullmoon Script
=======================

This is a simple little script that performs certain actions based on the change
of phases of the moon. More specifically, when the moon passes a certain
threshold of "fullness" and once it's dark out, the script will perform an
action such as sending a message to a channel and changing nick. I was planning
on using some web API to get sunrise/sunset times and moon illumination data,
but I decided I could just do the calculations myself and save some bandwith.

Not going to lie, this script exists solely because I wanted to make a joke
about my IRC nick.

Installing
----------
1. Clone this into your ~/.weechat/ruby/ directory
2. `rake`
3. In Weechat, `/ruby load fullmoon/fullmoon.rb`

To unload, simply `/ruby unload fullmoon`.

Commands
--------
*/moon*  
Shows the moon illumination percentage for a given date, or today if no date is
specified.


*/sunset*  
Shows the time of sunset for a given date, or today if no date is specified.

Status
------

Implemented:
* Sunset time and moon phase calculation logic
* Script registers with Weechat
* Configurable settings
* /moon command - shows the moon illumination for a given date
* /sunset - show sunset times for given date
* Timing code that does things at sunset if sufficient moon illumination

Yet to come:  
I don't plan to actively work on this script much more since it works for my
purposes, but if I were I'd probably implement a sunrise calculation that would
change your nick back.
