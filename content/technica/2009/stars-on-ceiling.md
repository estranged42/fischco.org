---
author: Mark Fischer
title: "Putting Stars On Our Ceiling"
date: 2009-04-11T07:15:00-07:00
images:
  - "/blog/2009/stars-TLC5940.jpg"
type: post
categories:
  - geek
  - arduino
  - article
aliases:
  - /blog/2009/4/10/putting-stars-on-our-ceiling.html

---

Playing around with silly electronics again.  This time the idea is to put twinkling stars on the ceiling of our bedroom.  I'm using two [TLC5940][1] chips to drive LEDs.  The chips are capable of 16 channels of [PWM][], so the stars can fade on and off nicely.

[1]: http://www.arduino.cc/playground/Learning/TLC5940
[PWM]: http://www.arduino.cc/en/Tutorial/PWM

<!--more-->

{{< img-fit
    "6u" "stars-TLC5940.jpg" ""
    "6u" "stars-prototype.jpg" ""
    "/blog/2009" >}}


Step 1 was a proof of concept.  Could I figure out how to hook up one of these chips to an Arduino, and get it to fade some LEDs on and off? Fortunately, the Arduino community is amazing, and someone has already written a fantastic library for this chip. (Thanks [acleone][2]!) The documentation on how to hook the chips up is all defined very nicely in the comments of the example programs in the library.

[2]: http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1218174457

    Basic Pin setup:
    ARDUINO                                     TLC5940
    -----------                                 ---u----
             13|                          OUT1 |1     28| OUT channel 0
             12|                          OUT2 |2     27|-> GND (VPRG)
             11|                          OUT3 |3     26|-> SIN (pin 7)
             10|-> BLANK (pin 23)         OUT4 |4     25|-> SCLK (pin 4)
              9|-> XLAT (pin 24)            .  |5     24|-> XLAT (pin 9)
              8|                            .  |6     23|-> BLANK (pin 10)
              7|-> SIN (pin 26)             .  |7     22|-> GND
              6|                            .  |8     21|-> VCC (+5V)
              5|                            .  |9     20|-> 2K Resistor -> GND
              4|-> SCLK (pin 25)            .  |10    19|-> +5V (DCPRG)
              3|-> GSCLK (pin 18)           .  |11    18|-> GSCLK (pin 3)
              2|                            .  |12    17|-> SOUT
              1|                            .  |13    16|-> XERR
              0|                          OUT14|14    15| OUT channel 15
    -----------                                 --------

Once I had a single chip working on a breadboard, it was time to plan out a morepermanentboard to house two chips. Two chips gives me 32 stars, which I figured was enough to start with. In order to fit the chips on the shield, I changed the transfer mode from SPI to bitbang inside of tlc_config.h, this let me just move from pins 11 and 13 over to 4 and 7, and let me squeeze in the TLCs right next to the arduino connector pins.

{{< img-fit
    "8u" "stars-shield.jpg" "Two TLC5940s on a shield"
    "/blog/2009" >}}


I changed the suggested resistor on the chip from 2k &Omega; to 100k &Omega;. The white LEDs I'm using are just way too bright with only 2k&Omega; of resistance. 100k knocks the brightness down to an acceptable level.

Next I need to start getting serious about wiring up a bunch of LEDs and start sticking them to my ceiling. I also have to figure out an elegant way of bringing in 30+ very thin wires and connecting them to their appropriate pins.

<strong>Update</strong>: [See how this project got finished][3].

[3]: /technica/2010/starfield/

