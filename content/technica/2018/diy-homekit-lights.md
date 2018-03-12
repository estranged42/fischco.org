---
author: Mark Fischer
title: "DIY HomeKit Enabled Lightstrips with Raspberry Pi"
date: 2018-01-06T09:00:00-07:00
draft: false
images:
  - "/technica/2018/homekit-lights/rwb.jpg"
type: post
categories:
  - geek
  - article
  - raspberrypi
  - electronics

---

## BlinkenLights!

We recently took the plunge and got a bunch of HomeKit enabled light switches for our house. After that we got a string of the Hue Lightstrips for pretty multi-colored lights!  After looking at the Hue strip, I thought that would be a cool project to build your own version. It also gave me an excuse to play with some [NeoPixels][] which I've wanted to play with for a while now. :)

[NeoPixels]: https://learn.adafruit.com/adafruit-neopixel-uberguide

<!--more-->

{{< img-fit
    "4u" "blue.jpg" ""
    "4u" "red.jpg" ""
    "4u" "rwb.jpg" ""
    "/technica/2018/homekit-lights" >}}

<iframe src="https://player.vimeo.com/video/254970981" width="640" height="360" frameborder="0" webkitallowfullscreen mozallowfullscreen allowfullscreen></iframe>
<p><a href="https://vimeo.com/254970981">DIY HomeKit Enabled Lightstrip</a> from <a href="https://vimeo.com/user77118469">Mark F</a> on <a href="https://vimeo.com">Vimeo</a>.</p>

### FadeCandy

I've had a couple of Raspberry Pis kicking around looking for a project, so I wanted to try and use that for this project. 

After spending a bunch of hours cruising around the [Adafruit][] website I came across the [FadeCandy][] board and associated server software. This little board connects to a host via USB, and directly controls the NeoPixel strips. You run a simple server app on the host its connected to, which then allows you to make really simple calls to the server to control the lights.  You can certainly control the lightstrips more directly, but having FadeCandy and the [Open Pixel Control][opc] server in between makes talking to them a lot easier.

Since the Raspberry Pi can run the OPC server, and has USB to connect the FadeCandy to, it makes it a great little platform for this.

[Adafruit]: https://www.adafruit.com/
[FadeCandy]: http://www.misc.name/fadecandy
[opc]: https://github.com/scanlime/fadecandy


### HomeKit Support with Homebridge

Getting the lights connected to my HomeKit setup proved to be a lot easier than I feared it would be once I found my way to the [Homebridge][] project. This project does all the heavy lifting of connecting to iOS and linking in to your Home you've set up in HomeKit.  There's already a [homebridge-opc][] module which will integrate with an Open Pixel Control server running on the same host! All you have to do is create a simple config file for Homebridge which describes your lightstrip setup and you're good to go!  Starting Homebridge even prints out an ASCII based QR code you can scan with your phone to link it!

[Homebridge]: https://github.com/nfarina/homebridge
[homebridge-opc]: https://github.com/plasticrake/homebridge-opc

### Parts List and Build

I prototyped the system out with a full Raspberry Pi 3, but for the final build I used a Pi Zero W since its so much smaller and cheaper.

I built a [parts list over on the Adafruit website][partlist] if you want specific links to all the components I used. I didn't list out things like a soldering iron, connection wire, headers, etc, although a lot of that stuff was also used.

[partlist]: https://www.adafruit.com/wishlists/456159

Here's a basic overview of the wiring diagram:

{{< img-fit
    "12u" "breadboard-diagram.png" ""
    "/technica/2018/homekit-lights" >}}

## Hardware

### Power

Lets start off looking at power.  All of the components we're using here are 5 volt parts.  So a good 5V power supply is crucial.  For a single strip of 60 NeoPixels, a [2 Amp power supply][2amp] should be fine if we're driving them with mostly a mix of colors, or not all fully bright. If you're mostly going to be driving them full white you may want a [beefier power supply][10amp]. See Adafruits excellent [NeoPixel Guide on Power][powerguide] for more details.

[powerguide]: https://learn.adafruit.com/adafruit-neopixel-uberguide?view=all#powering-neopixels
[2amp]: https://www.adafruit.com/product/276
[10amp]: https://www.adafruit.com/product/658

I needed a place to bring a bunch of these parts together to wire them up, so I used a [perma-proto board][permaboard]. This is a great little widget as it mirrors the internal row connections of a breadboard, making transferring the project from the breadboard simple.

[permaboard]: https://www.adafruit.com/product/1609

{{< img-fit
    "4u" "perma-board.jpg" ""
    "3u" "power-pins.jpg" ""
    "4u" "case-buttons-interrior.jpg" ""
    "/technica/2018/homekit-lights" >}}

I wanted a power switch on the case for this project, as well as a power indicator on the outside of the case. So I wired up a panel mount DC barrel jack to connect the power supply to, and run this in to some header pins I soldered to the perma-board. Power comes in on row D, ground on col 30 and vcc on col 29. Ground is tied into the proto-board ground line (blue -) with a little jumper on the bottom of the board. D29 connects to B29 with the built-in pad connections of the proto-board, allowing the power switch to be connected to the header pins on B28,B29. When the switch is closed, this makes the connection down to the proto-board's vcc line (red +). This power line then lets me easily pull vcc and ground off wherever its needed.

Other power related pieces here you can see are the giant [Electrolytic Capacitor][capacitor] to help protect things on initial power up. There's also a power-only microUSB plug I wired up to provide power to the Raspberry Pi. This way I only have to plug in a single power supply to the case. You _can_ power the Pi directly over the GPIO pins, but that lacks some protection that is in place when you power it from the microUSB port.

[capacitor]: https://www.adafruit.com/product/1589

### Raspberry Pi Zero

Moving over to the Raspberry Pi Zero itself, we have a couple of other connections coming in here.

{{< img-fit
    "6u" "raspberry-pi-zero.jpg" ""
    "6u" "raspberry-pi-zero-annotated.jpg" ""
    "/technica/2018/homekit-lights" >}}

#### Power LED

The power indicator was inspired by a great little writeup I found by [Zach on howchoo.com][powerlight]. By connecting the LED in the power switch to the TXT pin on the GPIO header, you can get a pretty good power indicator that lights up and flashes on boot, will stay on while the Pi is active, and turns off just a few seconds before the Pi finishes powering down completely.

Because the UART features this requires are disabled by default in newer versions of Raspbian, we need to enable this first.  Edit `/boot/config.txt` and add `enable_uart=1` at the end of the file.
[powerlight]: https://howchoo.com/g/ytzjyzy4m2e/build-a-simple-raspberry-pi-led-power-status-indicator


#### Graceful Shutdown Button

You can't just yank power from a Raspberry Pi without risking corruption of the filesystem on the SD card. So its necessary to cleanly shutdown the Pi before turning off the power. This requires somehow issuing a `sudo shutdown -h now` command to the running Pi. 

Adafruit has developed a [nifty small little C program][gpiohalt] that does just that.  It polls for a connection on a GPIO pin, and then executes the shutdown command when that pin is brought to ground.

[gpiohalt]: https://github.com/adafruit/Adafruit-GPIO-Halt

    git clone https://github.com/adafruit/Adafruit-GPIO-Halt
    cd Adafruit-GPIO-Halt
    make
    sudo make install

Once the little C program is compiled and installed, you need to call it on startup. The easiest way to do this is to add it to the `/etc/rc.local` file by adding the following line just before the `exit 0` at the end.

    /usr/local/bin/gpio-halt 21 &

This will run the next time the Pi starts up, so a reboot is required first: `sudo shutdown -r now`

The `21` there is the GPIO pin I'm using, its handy because its all the way at the other end and you don't have to counter header pins to find it! Its also conveniently located next to a ground pin, so its easy to solder on headers there.

Now simply hooking up a basic pushbutton to those pins will result in the Pi executing a clean shutdown. A few seconds later the LED goes off, and a few seconds after that its safe to switch off the power.

{{< img-fit
    "5u" "case-buttons-exterrior.jpg" ""
    "5u" "power-buttons.jpg" ""
    "/technica/2018/homekit-lights" >}}

#### USB On-The-Go (USB OTG)

The Raspberry Pi Zero has two microUSB jacks on it. One is just for power, so that one is the same as every other Pi. However the second one is known as a "USB On-The-Go" jack, and functions as a host connector like a standard USB-A jack.  This of course means you will likely need a special adaptor in order to connect anything useful to your Pi, like say a keyboard for initial setup.

I found two special cables to help with this, a basic [USB OTG -> USB A][otg-adaptor] adaptor so you can plug in regular things like keyboards. I also purchased a [USB OTG -> miniUSB cable][otg-mini] to connect directly from the Pi to the FadeCandy board. This just let me cut down on how much cabling I had to cram into the case.

[otg-adaptor]: https://www.adafruit.com/product/1099
[otg-mini]: https://www.amazon.com/gp/product/B01KG2A7AE/

### FadeCandy

The [FadeCandy][ada-fc] board is a really nice little piece of kit that will do the heavy lifting of driving the [NeoPixel][ada-neopix] strands. It works by communicating with some software running on the Pi called the Open Pixel Control server. This presents a REST interface to the world, and issues commands to the FadeCandy over standard USB cable. The FadeCandy board itself takes care of all the signalling required to actually drive the NeoPixel strand itself.

[ada-fc]: https://www.adafruit.com/product/1689
[ada-neopix]: https://www.adafruit.com/product/1138

I don't pretend to understand all of the things the board itself does, but math is involved!  This means I have to do less math in my code :)

There are a few limitations of the board to be aware of. While each board can control up to 8 strands of pixels, each strand is limited to 64 pixels, so its not possible to drive a single long strand. The board also _only_ works with RGB NeoPixels, not RGBW NeoPixels or the newer DotStar LED strands Adafruit offers. It may work with other cheaper strands, but YMMV.

{{< img-fit
    "3u" "fadecandy.jpg" ""
    "5u" "fadecandy-socket.jpg" ""
    "4u" "perma-board-pi.jpg" ""
    "/technica/2018/homekit-lights" >}}

I soldered a set of header pins to the FadeCandy board (it comes with these). Then I soldered a neat little [breakout helper][breakouthelper] to the perma-board so I could plug and unplug the FadeCandy board upside-down. They're a little expensive, so I wasn't ready to commit to having it permanently attached to something.

[breakouthelper]: https://www.adafruit.com/product/2104

### NeoPixels

The NeoPixel strand itself can be up to 64 pixels long. So either 1 meter of the 60 pixels per meter, or 2 of the 30 pixels per meter. I opted for 1m of 60 for the density and brightness.

I'm using/abusing microUSB plugs and sockets to connect the strands to the perma-board. I'm not really happy with how this part turned out however. Micro USB is soooo tiny that I couldn't solder the NeoPixel leads directly to the plug. I had to solder up some slightly smaller wires, then solder those to the NeoPixel leads. Thinner wires isn't great since you can't drive as much current through them, although for a single meter this should be fine.

{{< img-fit
    "6u" "neopixel-adafruit.jpg" "Courtesy of https://www.adafruit.com/product/1138"
    "6u" "usb-socket.jpg" ""
    "6u" "neopixel-connection.jpg" ""
    "6u" "usb-plug.jpg" ""
    "/technica/2018/homekit-lights" >}}

I was also hoping to panel-mount some jacks for the microUSB plug to connect to, but the panel mount connectors I bought don't seem to work as dumb pass-through connectors.

I'm still on the lookout for a better 4-pin panel mount plug/socket setup.

{{< img-fit
    "5u" "main-components-connected.jpg" ""
    "7u" "assembled-on.jpg" ""
    "/technica/2018/homekit-lights" >}}

## Software

### FadeCandy

Setting up the Open Pixel Control server is pretty simple. Just clone a git repository and run the included server program for the Pi.

Be sure to plug your FadeCandy board in first.

    git clone https://github.com/scanlime/fadecandy
    sudo ./fadecandy/bin/fcserver-rpi

This will start up the server software in the foreground. I'm just running it inside a `screen` session for now, but I will hopefully get around to properly daemonizing it to run at startup.

The best resource I've found for the FadeCandy board is the git repository: [https://github.com/scanlime/fadecandy](https://github.com/scanlime/fadecandy)

### HomeBridge

Installing HomeBridge on a Raspberry Pi differs a little bit from their default instructions. They do have a pretty good overview here: https://github.com/nfarina/homebridge/wiki/Running-HomeBridge-on-a-Raspberry-Pi

I was able to get mine working with the following set of commands:

    #!/bin/bash -ex

    # Install make
    sudo apt-get install make

    # Install NodeJS
    sudo apt-get install nodejs
    sudo apt-get install nodejs-legacy
    sudo apt-get install npm

    # https://github.com/nfarina/homebridge/wiki/Running-HomeBridge-on-a-Raspberry-Pi
    sudo apt-get install libavahi-compat-libdnssd-dev

    # Install homebridge
    sudo npm install -g --unsafe-perm homebridge
    sudo npm install -g homebridge-opc

Once installed, run homebridge once and it will create its basic config files in a `~/.homebridge/` folder in your home directory.  Homebridge does not need to be run as root.

    homebridge

Then quit out of it `ctrl-C` and edit the `~/.homebridge/config` file it created:

    {
        "bridge": {
            "name": "Homebridge2",
            "username": "CC:DD:FF:AA:00:11",
            "port": 51826,
            "pin": "032-95-209"
        },

        "description": "Pi Zero Homebridge.",

        "accessories": [{
           "accessory": "OpcAccessory",
           "name": "Strip B",
           "host": "localhost",
           "port": 7890,

           "lightbulbs": [
             { "name": "Strand",  "map": [ [0, 0, 60] ] }
           ]
        }]
    }

The username and pin just need to be unique on your network, so you may not need to change them unless you plan on running multiple homebridge setups on your network.

The strand syntax is from the homebridge-opc project, and more configuration options can be found at their github repository: https://github.com/plasticrake/homebridge-opc

The above config file creates a single 'light' with all 60 pixels.  You can split up the strand however you want though. In one of the pictures up top I split it into 3 'lights' of 20 pixels each. You can then control each section of the strand individually from your Home app on iOS.

Restart homebridge in another `screen` session, and scan the QR code it generates from your Home app on your iOS device. Your Home should now recognize all the lights you set up in your homebridge config.

## Final Thoughts

This project was a ton of fun, and the resulting multi-colored lightstrip is more versatile than the Hue Lightstrips. However they're not quite as bright as the Hue are, and it turns out it costs more to put it all together :).  A Hue lightstrip is about $80, and all the parts on my build list clock in well over $100. My setup can drive more than a single strip, and I've built it out with two ports, so adding another strip should only cost me $25, bringing the total cost slightly more in line with the commercial version.

I hope to figure out how to animate the lights next. If that works out then they'll clearly beat the commercial Hue lights!


----

