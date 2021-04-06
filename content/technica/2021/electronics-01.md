---
author: Mark Fischer
title: "Intro To Electronics for Kids: 01 Basic LED"
date: 2021-03-25T12:00:00-07:00
draft: false
images:
  - "/technica/2021/electronics/01-LED-2.jpeg"
type: post
categories:
  - geek
  - adafruit
  - electronics
  - qtpy
  - python
  - led
  - howto
  - class
  - electronics-intro
tags:
  - geek
  - adafruit
  - electronics
  - qtpy
  - python
  - led
  - howto
  - class
  - electronics-intro

---

Lesson one of my Spring 2021 Intro to Electronics for Kids class! This week we go over the basic kit, talk a little bit about electricity, and then connect up an LED to a power source to watch it glow!

<!--more-->

# The basic parts

The kit for this class consists of the following parts:

## Provided in the kit

* [Solderless Breadboard](https://www.adafruit.com/product/64)
* [QT-Py Microcontroller](https://www.adafruit.com/product/4600)
* [Assorted LEDs](https://www.adafruit.com/product/4203)
* [220 &#8486; Resistor](https://www.adafruit.com/product/2780)
* [10k &#8486; Resistor](https://www.adafruit.com/product/2784)
* [Photoresistor](https://www.adafruit.com/product/161)
* [Tactile Switch](https://www.adafruit.com/product/1119)
* [Buzzer](https://www.adafruit.com/product/160)
* [Jumper Cables](https://www.adafruit.com/product/1956)
* [Micro-USB to USB-C Adaptor](https://www.adafruit.com/product/4299)

[Here's all the parts in a list from Adafruit](http://www.adafruit.com/wishlists/523352).

## You Will Need

* A USB Power Cable - EIther Micro-USB or USB-C
* A USB Power Supply - A cellphone charger or battery works great for this


## You might want

* An extension cord if your USB cable isn't long enuogh to reach the table you're working on
* A tray or bowl to hold the peices you're not using

# Step 1: The Breadboard

Solderless breadboards are a really great experimenting tool. It allows us to easily connect, disconnect, and reconnect different components without having to twist wires together, or use a more permenant connection like soldering. The breadboard we're using has 4 areas. On the edges are two long columns with blue and red bars along side. These are labeled + and - at the ends. These are usually used as power rails, with + for positive, and - for negative. A lot of times we call the negative power rail 'ground'. Each hole in these columns is connected under the board so anything plugged into one hold of the + rail is connected to anything plugged into any other hole.

The other two areas are connected in rows instead of columns. So row 1, columns a, b, c, d, and e are all connected together. There is a central dividing line separating the two halves of the breadboard. On the other side, row 1, columns f, g, h, i, j are also all connected together. This gives us 60 separate rows to use as connections for components, plenty for our experiments.


# Step 2: The QT-Py Microcontroller

First, lets place the QT-Py microcontroller onto the breadboard.

Orient the breadboard so that the number 1 row is on the left, and the number 30 is on your right.

Line up the QT-Py with the USB-C plug on the left, and gently press the pins into the breadboard with pins 1 through 7. You might need to wiggle the microcontroller back and forth a little bit to ease it into the breadboard.

{{< img-fit
    "10u" "01-Breadboard.jpeg" ""
    "/technica/2021/electronics" >}}

Once you have the microcontroller plugged into the breadboard. Go ahead and hook up your USB cable to power, and plug it into the QT-Py microcontroller. If powered, the on-board LED should change colors and then stay on red.

# Step 3: The LED

Now let's place our Light Emitting Diode, or LED onto the breadboard. You'll notice that the LED has two legs, and one is slightly longer than the other. This is important, as electricity can only flow through a LED in one direction, but not the other.

The longer leg is the positive leg, and must be connected to the power source.  Plug the LED into the breadboard with the long leg in row 25, and the short leg in row 26.

{{< img-fit
    "10u" "01-LED-0.jpeg" ""
    "/technica/2021/electronics" >}}

# Step 4: The Resistor

We're using pretty low voltages in our circuit (only 3 volts), with very little power (only 500 milli-Apms).  However a LED may sometimes draw a lot of current, so it is always safest to have a current-limiting resistor in the circuit with the LED. Resistors are measured in Ohms, and use the greek symbol capitol Omega – __&#8486;__ – to represent it. In our kit we have two resistors, a 10,000 &#8486;  resistor (usually abbreviated as 10k &#8486;) and a 220 &#8486; resistor. 

The reistor is omni-directional, meaning it does not matter which way you put it into the circuit. Plug one leg of the reistor into __(26, c)__ in front of the LED, the same row the short leg of the LED is connected. Plug the other leg into the very top row of the breadboard with the blue line running along side.

The bigger resistor in our kit is the 10k &#8486; one. The higher the resistance, the less current is allowed to flow through the circuit, and the dimmer the LED will be. A lower value resistor allows more current to flow, and the LED will be brighter.

It doesn't matter which resistor you use here to start. Try changing them later to see the difference in brightness.

{{< img-fit
    "10u" "01-Resistor.jpeg" ""
    "/technica/2021/electronics" >}}

# Step 5: Positive Power

We're using the microcontroller to provide 3 volts of power for us. This will come from the pin on the microcontroller labelled 3V. This is row 3 on the upper side of the breadboard, columns f, g, h, i, j.  The microcontroller covers up columns f and g, so we'll connect one of our jumper wires up to **(3, i)** on our breadboard. This needs to connect to the positive leg of our LED, which we have connected to row 25. So lets plug the other end of this wire into **(25, a)**. It doesn't matter what color you use.

{{< img-fit
    "10u" "01-LED-2.jpeg" ""
    "/technica/2021/electronics" >}}

# Step 6: Ground

Lastly we need to complete our circuit by closing connecting the negative, or ground, rail back to the ground pin on the microcontroller. We can do this by connecting another jumper wire from **(2, j)** to the negative rail, the one with the blue line next to it.

Our LED should light up at this point!

{{< img-fit
    "10u" "01-LED-1.jpeg" ""
    "/technica/2021/electronics" >}}


# Step 7: Experiment

What happens if you change the resistor?

What happens when you disconnect any of the jumper wires?

What happens when you unplug the microcontroller from the USB cable?

What happens if you put in a different colored LED?

What happens if you put the LED in the wrong way?

What happens if you plug in more than one LED to rows 25 and 26?

What happens if you move a jumper wire to a different hole in the same row?

# Wrapup

That's it for this lesson. In this we learned:

* Electricity flows in a close loop, called a circuit
* LEDs have a direction, and the long leg is the positive leg
* Reistors limit the flow of current. The higher the resistance, the dimmer the LED

# Diagram

{{< img-fit
    "10u" "01-LED_bb.png" ""
    "/technica/2021/electronics" >}}
