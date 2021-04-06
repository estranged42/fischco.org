---
author: Mark Fischer
title: "Intro To Electronics for Kids: 03 Digital LED Button"
date: 2021-04-05T12:00:00-07:00
draft: false
images:
  - "/technica/2021/electronics/03-Digital-Button.jpeg"
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

Lesson three of my Spring 2021 Intro to Electronics for Kids class! Last lesson we saw how a button can be used to close a circuit, lighting up an LED. However the LED only remains lit while the button is pressed. Can we instead use the button to toggle the LED on and off?

<!--more-->

[{{< figure class="pull-right" src="/images/PDF.png" caption="**Lesson 3.pdf**" >}}](/technica/2021/electronics/03-Digital-Button.pdf)
# Printable PDF

Here's a printable PDF of this lesson so you can follow along without having to have this page up on a screen.


# Microcontrollers

In the first two lessons, we only used the QT-Py Microcontroller as the power source for our circuit. However this microcontroller is a tiny, powerful computer! It is running a simple program that I wrote for these lessons. You won't have to write any code for these lessons. At the end though, if you would like, you can re-program the microcontroller to create your own programs and experiments.

Microcontrollers allow you to take in data, and make changes to circuits based on the logic of the program. For this lesson, the program will be waiting to detect when the button is pressed. When it detects the button being pressed, the program will toggle the LED. If the LED is off, it will turn it on.  If the LED is on, it will turn it off.

In this circuit, the button is not directly connected to the LED. It is only used as the signal to the program to turn the LED on or off.


# Diagram

Rather than a step by step guide with photos, lets try building our circuit from a diagram this time. If you still have the circuit from Lesson 2 built, remove the wires connected to the button.

Carefully examine the diagram below. Add the wire from the microcontroller to the LED: **(6, a)** to **(25, a)**.

Then add the wire from the microcontroller to the button:  **(5, i)** to **(15, i)**.

Finally add the wire from the button to ground:  **(17, i)** to **ground rail**.

{{< img-fit
    "10u" "03-LED_Button_bb.png" ""
    "/technica/2021/electronics" >}}

If you have everything connected correctly, when you press the button the LED should light up and stay on once you let go. Pressing and releasing the button again will turn the LED off.

{{< img-fit
    "10u" "03-Digital-Button.jpeg" ""
    "/technica/2021/electronics" >}}

# Experiment

What happens if you swap the two wires connected to the button?


# Tinkercad

[Experiment with this circuit on Tinkercad!](https://www.tinkercad.com/things/hszAD3P63KZ)

Note that Tinkercad does not support the Adafruit QT-Py microcontroller. So I had to write slightly different code that would work with an Arduino UNO instead. The functionality is mostly the same, but the wiring is fairly different, as the UNO is not as fancy as the QT-Py, and requires some extra wiring and resistors.