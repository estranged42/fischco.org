---
author: Mark Fischer
title: "Intro To Electronics for Kids: 02 Button Powered LED"
date: 2021-04-01T12:00:00-07:00
draft: false
images:
  - "/technica/2021/electronics/02-Button-LED.jpeg"
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

Lesson two of my Spring 2021 Intro to Electronics for Kids class! This week we add a button to our LED so that we can control the blinking!

<!--more-->

# Step 1: Setup

If you still have the circuit from [Lesson 1][lesson1] built, remove the positive wire running from the 3V pin of the microcontroller to the positive leg of the LED, row 25.

If you're starting over from scratch, review [Lesson 1][lesson1] and follow steps 1, 2, 3 and 4 from that and then come back here.

[lesson1]: ../electronics-01#you-might-want

# Step 2: The Button

In lesson 1, we saw that the LED does not light up until the circuit is complete. There cannot be any breaks in the wires or connections of our circuit. If we pull out one end of just one wire from our breadboard, we interrupt the circuit and the LED goes off.

A button, or switch allows us more control over completing a circuit than simply plugging and unplugging one of our jumper wires.

Find one of the large, square, pushbuttons from your kit. We will put the button about in the middle of our breadboard, straddling the gap in the center, with the pins plugging into rows 15 and 17.

{{< img-fit
    "10u" "02-Button.jpeg" ""
    "/technica/2021/electronics" >}}

When you push the button, it will connect the two pins plugged into rows 15 and 17, allowing electricity to flow through it.

# Step 3: Positive Jumper Wires

Now we need to connect our new button into the circuit. First let's connect a jumper wire from the 3V pin of the microcontroller **(3, i)** to our button, **(15, i)**.

Next connect the other pin from our button **(17, i)** to the positive leg of our LED **(25, b)**.

{{< img-fit
    "10u" "02-Button-2.jpeg" ""
    "/technica/2021/electronics" >}}

# Step 4: Ground

If you don't have the ground rail connected still from Lesson 1, connect it now by adding a jumper wire from **(2, j)** to the negative, blue rail.

{{< img-fit
    "10u" "02-Ground.jpeg" ""
    "/technica/2021/electronics" >}}

# Experiment

With everything connected, and the microcontroller plugged into USB power, when you push the button, the LED should light up!

Why does the LED only light up when you hold the button down?

What happens if you connect up more than one LED to rows 25 and 26?

# Diagram

{{< img-fit
    "10u" "02-LED_Button_bb.png" ""
    "/technica/2021/electronics" >}}

Look at the diagram above and compare it to your circuit. Many times a diagram like this is used instead of step-by-step photos. Diagrams allow us to represent our circuit with a simplified set of images. It is often easier to use a computer to draw a diagram like this than it is to create all the circuits by hand and photograph them.

# Tinkercad

[Experiment with this circuit on Tinkercad!](https://www.tinkercad.com/things/giZT3CbfX2l)