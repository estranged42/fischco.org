---
author: Mark Fischer
title: "Home Automation"
date: 2006-06-15T18:00:00-07:00
type: post
categories:
  - geek
  - automation

---

A few years ago, I was reading about home automation, and I've been hung up on it ever since.  You know that stuff that lets you turn on and off lights, adjust  your AC, and water your lawns automatically.  Ok well the lawn part is silly for us in Tucson, but the rest of it still interested me.  The basics of this, X10, have been around for years.  I remember when I was a kid looking at the Tandy X10 stuff in Radio Shack.  I always wondered why everyone didn't have this stuff in all their houses.  Well after reading more about it, it turns out that the X10 protocol just isn't that reliable.  

<!--more-->

Well times and technologies change.  About two years ago, a company called SmartHome that was already into making X10 devices decided to come up with a new protocol, [Insteon][1].  (Take a read through [some of the specs][2] for it, its pretty fascinating how it works.) Their main claim was reliability.  After another few months recently of reading about it, I decided to take the plunge and see if this whole thing was worth it.

[1]: http://www.insteon.net/
[2]: http://www.insteon.net/specs.html

So far, it is way cool.

For my birthday, Angela, my parents and Angela's parents got me the basics I needed to setup an Insteon network.  Of course first I needed something to control, so we got 1 [lightswitch][1].  Next I needed 2 units to bridge the two legs of the house power lines.  Evidently most houses have 2 separate 110 lines, and for commands to get from one leg to the other, you need a pair of [RF SignalLinc][2] units.  We also needed a unit that would let the computer plug into the powerline network so we got one [PowerLinc Controller][3].  Lastly we needed some software to run on a Mac that would know how to deal with this whole mess, so I got a copy of [Indigo][4] from Perceptive Automation.

[1]: http://store.indigodomo.com/catalog/product_info.php?cPath=36&products_id=94
[2]: http://store.indigodomo.com/catalog/product_info.php?cPath=36&products_id=91
[3]: http://store.indigodomo.com/catalog/product_info.php?cPath=36&products_id=98
[4]: http://www.perceptiveautomation.com/indigo/


After plugging in the plug-in stuff, and shutting off the power and re-wiring the switch, I was ready to go.  To my amazement, it worked!  I could now sit at my computer and turn my living room lights on and off!  Once the awe wore off, Angela and I began brainstorming about what we could actually use this for.  First we came up with a simple script to run at night.  The light switch has never been near the bed, so I wrote a little script in Indigo that dimmed the lights to about 60%, then after 2 minutes dimmed them to 25%, then after another 2 minutes turned them off.  This gave us enough time to get settled and into bed and the lights just turn themselves off after a bit.  We liked.  

Since Indigo runs on a Mac, and supports [AppleScript][1], we figured it could control [iTunes][2]
 too, and get some music into the mix.  So next I wrote a little wake-up script for Indigo.  At a preset time, the script fires and turns on iTunes at a fairly low volume level.  It also turns on the lights dimly at about 20%.  Over the next 5 minutes the lights gradually get brighter, and the music gradually gets louder.  All in all its a bit too effective at waking us up, which is the point I suppose.  It sure beats a blaring alarm clock buzzer.

[1]: http://www.apple.com/macosx/features/applescript/
[2]: http://www.apple.com/itunes/overview/

After fiddling with this network and my 1 switch for two weeks, we decided that it worked well enough to get a few more controllable switches.  So we bought a [relay switch][1] to control our ceiling fans (can't use dimmer switches for fans).  We got a [simple dimmer switch][2] to control the lights outside the garage, and a [basic appliance switch][3].  Lastly we got a fairly complex [8-button KeypadLinc][4].  All the new switches wired in easily, and the computer recognized them right away and all was well.  

[1]: http://store.indigodomo.com/catalog/product_info.php?cPath=36&products_id=106
[2]: http://store.indigodomo.com/catalog/product_info.php?cPath=36&products_id=101
[3]: http://store.indigodomo.com/catalog/product_info.php?cPath=36&products_id=108
[4]: http://store.indigodomo.com/catalog/product_info.php?cPath=36&products_id=97

We put the appliance module on a large box fan that we use during the summer to help move the air around. With the new switch on the ceiling fans, we can now turn the fans off at about 1am when it gets a little cold to have them blowing, and back on at 9am when the good old Tucson heat begins to crank it up.  

The most interesting switch is the KeypadLinc.  With 1 button dedicated to turning on and off the kitchen lights, we have 7 buttons available to do pretty much whatever else we can think of.  One of the neat things about most Inseton devices is that you can cross-link them to control each other.  So I cross-linked button 2 on the keypad to the living-room lights, and button 3 to the ceiling fans.  This lets you turn the fans and lights on and off from either their real switches by the front door, or from the keypad in the kitchen.

Anytime you click a button on any Insteon switch, it broadcasts that action to the network, and Indigo running on the Mac picks that up.  This gives you pretty much unlimited flexibility to do whatever you dream up.  First off I configured Indigo to fire off the 'night-time fade the lights off' script whenever button 8 was pressed.  Indigo knows what time it is, and also what time sunrise and sunset are, so the outside garage lights now come on at night and turn off in the morning.

We have a pretty small house, and there aren't many more switches I can think of that I'd want to replace.  Maybe a switch for the hallway lights, or a bathroom switch.  At some point I hope they come up with an Insteon version of some of the older [thermostats][1] and [temperature sensors][2] so the computer can look at the current temperature, get a forecast from the NOAA website, and then set the thermostat more appropriately.  The Insteon stuff is all still fairly new, so we're waiting for irrigation controllers, HVAC, motion detectors, remotes etc that are all available for X10.

[1]: http://www.smarthome.com/3045B.html
[2]: http://store.indigodomo.com/catalog/product_info.php?cPath=25&products_id=37

So this has been really cool, and now we're settling into our more automated house.  As time goes on we'll probably think up more things to do with what we have, and perhaps add a few more controllable devices.  It's definitely good stuff!

