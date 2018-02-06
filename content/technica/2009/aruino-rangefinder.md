---
author: Mark Fischer
title: "Arduino Rangefinder"
date: 2009-03-17T04:00:00-07:00
images:
  - "/blog/2009/arduino-board.jpg"
type: post
categories:
  - geek
  - articles
  - arduino
aliases:
  - /blog/2009/3/17/arduino-rangefinder.html

---



I've always been a programmer.  However, the world of hardware has always intrigued me.  I've always been somewhat interested in the ability for electronics to actually *do* something in the real world, and not just push pixels around a screen.

I first heard about the [Arduino][] micro-controller world on an episode of [MacBreak Weekly][]. [Andy Ihnatko][] was talking about it for an upcoming talk he was giving.  Basically the Arduino is an open-source micro-controller.  It connects to your PC via a USB port.  There's a custom IDE built for it that runs on Macs, Windows and Linux.  The basic idea is that you can now easily control simple voltages on pins.  Connect them to sensors, motors, LEDs etc, and control the real world from a very easily accessible starting point.

[Arduino]: http://www.arduino.cc/
[MacBreak Weekly]: http://twit.tv/mbw81
[Andy Ihnatko]: http://ihnatko.com

<!--more-->


So I finally got around to ordering the standard Arduino board, some sensors, a breadboard, and started playing.

An interesting concept with the Arduino world, is the idea of a 'shield'.  Basically a shield is a board that fits on top of the base Arduino, and adds some functionality to the basic setup.  A proto-shield is just a shield that gives you a small space for prototyping.  The SparkFun shield also gives you a couple of LEDs with resistors in place, and some switches to play with.

The proto-shield comes as a kit, so I got to practice my soldering skills.  I had never really soldered on a board before, but after a few minutes of poking around, I eventually got the hang of it.  Shield assembled, I was amazed at how fast and easy it was to start getting readings from the ultrasonic sensor.  The following few lines of code were all that was needed to read the sensor value, and send it to a listening serial port:

    int sensorValue = 0;
    int sensorPin = 1;

    void setup() { 
      Serial.begin(9600);
    }

    void loop() {
      sensorValue = analogRead(sensorPin);
      Serial.println(sensorValue);
    }

The input / output pins on the Arduino board are all numbered, so you just pick a pin, hook up your sensors, and you're off!

Once I figured out how to get reliable readings from the sensor, I figured a simple thing to build would be a system to see if I was at my desk or not.

I pulled the parts off the protoshield, and built a more permanent set of boxes.  One box for the Arduino, and another for the sensor.  This let me position the sensor in an appropriate spot, and allowed me to plug the Arduino box into a USB port.

{{< img-fit
    "6u" "arduino-board.jpg" ""
    "6u" "arduino-rangefinder-1.jpg" ""
    "6u" "arduino-rangefinder-2.jpg" ""
    "6u" "arduino-rangefinder-3.jpg" ""
    "/blog/2009" >}}


The two buttons let me set the range at which the sensor will trigger an &#8220;Away&#8221; or &#8220;Here&#8221; message back to the computer.  A simple program running on my mac then picks up the signal from the Arduino, and relays it to a web service that then tracks my presence.

Parts List:

* [Arduino Duemilanove](http://www.sparkfun.com/commerce/product_info.php?products_id=666)
* [Maxbotix LV-EZ1 Ultrasonic Range Finder](http://www.sparkfun.com/commerce/product_info.php?products_id=639)
* [Arduino ProtoShield Kit](http://www.sparkfun.com/commerce/product_info.php?products_id=7914)


Code:

[ProximitySensor v5](/files/ProximitySensor5.pde)



-----
