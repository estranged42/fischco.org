---
author: Mark Fischer
title: "WiFi LCD Status Screen"
date: 2018-03-04T16:00:00-07:00
draft: false
images:
  - "/technica/2018/status-screen/status-screen.jpg"
type: post
categories:
  - geek
  - article
  - adafruit
  - arduino
  - electronics
  - lcd
  - huzzah32
  - esp32

---

I recently picked up one of Adafruit's new [HUZZAH32][] Feather development boards, without having a clear project in mind for it. However after browsing the Adafruit forums, I stumbled across someone who was making a sort of status screen for their office, and I thought I would try that out.

The basic idea is to have a little box with an LCD screen on it which would display my current status.  Like, if I'm in a meeting, at lunch, or home sick.

<!--more-->

{{< img-fit
    "8u" "status-screen.jpg" ""
    "/technica/2018/status-screen" >}}


## Asumptions

For this guide I assume the following knowledge and prior setup:

* You have a basic understanding of Arduino boards, sketches, and uploading. This is not intended as a first guide to Arduino.
* You have a [HUZZAH32 Feather][huzzah_feather]
* You have read throug the [Adafruit HUZZAH32 Feather overview guide][guide]
* You have installed Espressif Arduino repository and SiLabs USB drivers as detailed on the [Using with Arduino IDE guide page][arduino_setup]
* You have created an account at [adafruit.io][] or have some other way to host data for HTTP retrieval. 

[huzzah_feather]: https://www.adafruit.com/product/3405
[guide]: https://learn.adafruit.com/adafruit-huzzah32-esp32-feather
[arduino_setup]: https://learn.adafruit.com/adafruit-huzzah32-esp32-feather/using-with-arduino-ide
[adafruit.io]: https://io.adafruit.com

### Basic requirements:

* Network capabilities of some sort. WiFi seems the best for this.
* HTTP Stack available to make API calls.
* Some sort of screen.

I had an old character LCD from years ago, so I decided to try and use that as a screen, and the [HUZZAH32][] has on board WiFi and HTTP example code, so I was off to the breadboard!

[HUZZAH32]: https://learn.adafruit.com/adafruit-huzzah32-esp32-feather

## Design and Layout

First I set out connecting up the 16x2 Character LCD screen. Since the Feather has plenty of IO pins, I can just use use 6 pins to connect directly to the LCD screen without requiring the I2C backpack (which is super useful if you don't have tons of pins).

    // Connect direct with GPIO pins
    //
    // LCD          Feather
    // --------     --------
    // 4  - RS      25
    // 6  - EN      26
    // 14 - DB7     32
    // 13 - DB6     15
    // 12 - DB5     33
    // 11 - DB4     27

The LCD screen also needs a potentiometer connected to control the screen brightness, as well as a bunch of other pins connected to 5V and Ground. See [Adafruit's learning guide on LCDs][lcdguide] for a great overview of these little screens.

[lcdguide]: https://learn.adafruit.com/character-lcds

I also included a pushbutton to toggle the LCD backlight, so that its not always on.

These types of Character LCD screens need +5V power for VCC and to light the backlight. The logic pins seem to be 3.3V tolerant though fortunately.  So we need to pull power off the USB pin which will be 5V when you're powering the HUZZAH32 via USB. If I want to power this from a battery, I'll have to figure out some way to boost the 3.7V from a LiPoly up to 5V to power the screen.

{{< img-fit
    "6u" "protoboard-schematic.png" ""
    "6u" "breadboard-startup.jpg" ""
    "/technica/2018/status-screen" >}}


After connecting everything up on a breadboard for testing, it was time to make it more permanent.

## Perma-Proto Board Assembly

Adafruit sells these great little [perma-proto][] boards. They're laid out just like a breadboard, with power rails and a center gutter etc. So you can pretty much just pick up your design from the breadboard, stick it on the perma-proto and solder it up!

[perma-proto]: https://www.adafruit.com/product/1609

Since I'm not using all of the pins on the Feather, I only need to solder on a few headers to the perma-proto for stability.  I'm also going to mount the LCD screen on the under side of the proto board.


{{< img-fit
    "6u" "build01-protoboard.jpg" ""
    "6u" "build02-protoboard-back.jpg" ""
    "6u" "build03-huzzah.jpg" ""
    "6u" "build04-lcd.jpg" ""
    "/technica/2018/status-screen" >}}

Next I wired up the rest of the connections, potentiometer, and pushbutton.

{{< img-fit
    "6u" "build06-wires.jpg" ""
    "6u" "build08-back.jpg" ""
    "6u" "build09-huzzah.jpg" ""
    "6u" "build10-sick.jpg" ""
    "/technica/2018/status-screen" >}}

I did make one mistake while soldering things up.  I originally put the pushbutton straddling the center gutter. This had the unintended side affect of bridging the +5V power from above and connecting it down to one of the LCD data pins.  This took me several frustrating hours with a multimeter to track down. :)  Fortunately it was an easy fix to cut the leg off the pushbutton.

{{< img-fit
    "6u" "build07-cut-button.jpg" ""
    "/technica/2018/status-screen" >}}

## 3D Printed Case

This was also my first time designing a 3d printed case for a project.  I spent a couple hours watching the Adafruit 3D modeling tutorials, especially the one on [designing parametric snap-fit cases][casevideo].  A couple of hours later, I had my first case design!

{{< img-fit
    "6u" "case01.png" ""
    "6u" "case02.png" ""
    "/technica/2018/status-screen" >}}

I'm really fortunate to work at [The University of Arizona][uofa], and we have a great little [maker space][ispace] as part of the library system, and they do 3D printing. So I was able to upload my STL files to them and a couple of days later went over to pick up my prints.

[casevideo]: https://www.youtube.com/watch?v=VVmOtM60VWw&list=PLjF7R1fz_OOVsMp6nKnpjsXSQ45nxfORb&index=5
[uofa]: http://www.arizona.edu
[ispace]: https://new.library.arizona.edu/ispace

{{< img-fit
    "6u" "build11-case01.jpg" ""
    "6u" "build15-case05.jpg" ""
    "4u" "build12-case02.jpg" ""
    "4u" "build13-case03.jpg" ""
    "4u" "build14-case04.jpg" ""
    "/technica/2018/status-screen" >}}



## Arduino Code

### WiFi

First off was trying to get the Feather onto my WiFi.  This was a pretty new development board from Adafruit in 2018 so there wasn't a whole lot of great how-tos on it yet. Fortunately espressif, the makers of the ESP32 chip on the Feather have a pretty decent [Arduino core with example sketches up on github][espressifgithub]. Particularly the [BasicHttpClient][] example.

[espressifgithub]: https://github.com/espressif/arduino-esp32
[BasicHttpClient]: https://github.com/espressif/arduino-esp32/blob/master/libraries/HTTPClient/examples/BasicHttpClient/BasicHttpClient.ino

I tend to hide the SSIDs of my networks at home, but this seems to cause problems with the Feather. So I created a guest network, 2.4GHz, with the SSID visible. I could get WPA2 security working fortunately.

```C
#include <WiFi.h>
#include <WiFiMulti.h>

void setup()
{
    WiFiMulti.addAP("arduino", "<password>");

    while(WiFiMulti.run() != WL_CONNECTED) {
        Serial.print(".");
    }

    Serial.println("");
    Serial.println("WiFi connected");
    Serial.print("IP address: ");
    Serial.println(WiFi.localIP());
    Serial.println(WiFi.macAddress());
}
```

Getting on WiFi turned out to be pretty easy for the most part, so thanks so much to the espressif folks for these libraries!

The `WiFi.macAddress()` method seems to return a random MAC address until you actually connect to a network. So if you need the MAC address, be sure to connect to a network you know you can get onto first.

### adafruit.io

I need to pull down my current status from somewhere on the web. My first attempt was just a static text file on a web server I have access to. But updating it there was a bit of a pain, and not very "Internet of Things-y". So I decided to play around with [adafruit.io][], the IoT service Adafruit offers.

Since this project just needs to read data from a feed, we don't need to mess around with API keys or any form of authentication.  Create a new feed in your adafruit.io console, and make it public.

{{< img-fit
    "8u" "adafruitio-feed.png" ""
    "/technica/2018/status-screen" >}}

In the feed, you can manually enter data to set the status.

{{< img-fit
    "8u" "adafruitio-feed-data.png" ""
    "/technica/2018/status-screen" >}}

Once that is set up you can test your feed in any web browser by simply visiting the following URL:

    http://io.adafruit.com/api/v2/estranged/feeds/mark-status/data/?limit=1&include=value

Substitute your username and feed key for `estranged` and `mark-status` respectively.  Limiting the feed to 1 item, and only getting the `value` field limits the size of the JSON response, making it easier to parse. You can play around with removing those parameters from the URL and see how the results change.

With the feed in place, and WiFi connected, we're ready to retrieve our feed.  Adafruit maintains an IO library, but for this project I wanted to try my hand at parsing JSON directly so that I know how to do it for arbitrary API calls. It turns out there is a fantastic [ArduinoJson][] library out there which works really well, and you can just add via the library manager in the Arduino IDE. I'm also using the HTTPClient library that comes with the Espressif esp-32 Arduino setup.

> Note! This example only works with un-encrypted HTTP URLs.  Not with HTTPS connections. The HTTPClient library does support SSL/TLS certificates but the setup is more involved. See the [BasicHttpClient][] example for hints on how to work with certificates, but I have not got this working yet.

[ArduinoJson]: https://arduinojson.org/

```C
#include <HTTPClient.h>
#include <ArduinoJson.h>

StaticJsonBuffer<200> jsonBuffer;

void loop()
{
    // Create an HTTPClient object
    HTTPClient http;

    // Setup our URL
    http.begin("http://io.adafruit.com/api/v2/estranged/feeds/mark-status/data/?limit=1&include=value");

    // start connection and send HTTP header
    int httpCode = http.GET();

    // httpCode will be negative on error
    if(httpCode > 0) {
        // HTTP header has been sent and Server response header has been handled
        Serial.printf("[HTTP] GET... code: %d\n", httpCode);

        // Successful connection: Status code of 200
        if(httpCode == HTTP_CODE_OK) {
            // Retrieve and print out the raw response
            String payload = http.getString();
            Serial.println(payload);

            // jsonBuffer must be cleared each time through the loop, otherwise it fills up.
            jsonBuffer.clear();
            // be careful to never reference jsonArray outside this loop, as it will be undefined
            // when the buffer is cleared.
            JsonArray& jsonArray = jsonBuffer.parseArray(payload);
            
            // Retrieve the value field from the json data and print it.
            const char* statusValue = jsonArray[0]["value"];
            Serial.println(statusValue);
        }
    } else {
        Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
    }

    http.end();

    delay(60000);
}
```



### LCD Screen

I had an old 16 column, 2 row Character LCD screen I got around 10 years ago when I first started playing with Arduinos. Fortunately they haven't really changed and are still well supported on new development boards. [Adafruit of course has a great guide][lcd-guide] on getting started with these sort of screens. Since I have plenty of IO pins on the Feather, I'm just using 6 data pins to connect to the LCD screen. 

[lcd-guide]: https://learn.adafruit.com/character-lcds

```C
#include "Adafruit_LiquidCrystal.h"

#define PIN_RS 25
#define PIN_EN 26
#define PIN_DB7 32
#define PIN_DB6 15
#define PIN_DB5 33
#define PIN_DB4 27

Adafruit_LiquidCrystal lcd(PIN_RS, PIN_EN, PIN_DB4, PIN_DB5, PIN_DB6, PIN_DB7);

void setup()
{
    lcd.begin(16, 2);
    lcd.print("Starting up");
}
```

<img src="/technica/2018/status-screen/wifi.gif" width="75" style="float: right; display: inline-block;">

One additional fun thing I learned about on the [Adafruit LCD guide][lcd-guide] was that you can program up to 8 custom characters on the LCD, and the display them wherever you'd like.  I thought it would be fun to animate a little WiFi icon while it was starting up, so I created 3 separate custom characters, and then cycle through them during the startup phase.


I found just sort of mapping out the characters as a byte array works pretty well.  Each `1` is a pixel of the character that will be on, and the zeros are all off.


```C
// Custom Character Designer
// https://www.quinapalus.com/hd44780udg.html
byte wifi3[8] = {
  B00000,
  B01110,
  B10001,
  B00000,
  B00100,
  B01010,
  B00000,
  B00100,
};

void setup()
{
  lcd.begin(16, 2);
  
  // Write the custom character to the LCD. There are 8 custom slots, 0-7. We're writing to slot 2.
  lcd.createChar(2, wifi3);
  
  // Set the cursor position on the LCD screen, then display your custom character
  // 0 is row 1
  // 15 is the last character on the row
  lcd.setCursor(15, 0);
  lcd.write(byte(2));
}
```

## Conclusion

This was a really fun project, and one of the first that sort of feels 'finished' to me, as it has a little case and everything. I will probably do another revision of the case, as I forgot to include a hole for the USB cable to thread through. Also the board stack inside is a little loose, since its only connected together with header pins. I'm going to try and include some more mounting posts on the side for the Feather to screw into.

I hope you found it interesting and helpful. If you have any questions hit me up on Twitter.

---

Like this article or have questions? <a href="https://twitter.com/intent/tweet?screen_name=estranged&url=http%3A%2F%2Fwww.fischco.org%2Ftechnica%2F2018%2Fstatus-screen" class="twitter-mention-button" data-show-count="false">Tweet to @estranged</a><script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

---

## Full Code

```C
/*
 *  This sketch sends a message to a TCP server
 *
 */

#include <WiFi.h>
#include <WiFiMulti.h>
#include <HTTPClient.h>
#include "Adafruit_LiquidCrystal.h"
#include <ArduinoJson.h>

WiFiMulti WiFiMulti;

// Connect direct with GPIO pins
//
// LCD          Feather
// --------     --------
// 4  - RS      25
// 6  - EN      26
// 14 - DB7     32
// 13 - DB6     15
// 12 - DB5     33
// 11 - DB4     27
//

#define PIN_RS 25
#define PIN_EN 26
#define PIN_DB7 32
#define PIN_DB6 15
#define PIN_DB5 33
#define PIN_DB4 27

Adafruit_LiquidCrystal lcd(PIN_RS, PIN_EN, PIN_DB4, PIN_DB5, PIN_DB6, PIN_DB7);

// Custom Character Designer
// https://www.quinapalus.com/hd44780udg.html
byte wifi1[8] = {
  B00000,
  B00000,
  B00000,
  B00000,
  B00000,
  B00000,
  B00000,
  B00100,
};

byte wifi2[8] = {
  B00000,
  B00000,
  B00000,
  B00000,
  B00100,
  B01010,
  B00000,
  B00100,
};

byte wifi3[8] = {
  B00000,
  B01110,
  B10001,
  B00000,
  B00100,
  B01010,
  B00000,
  B00100,
};

StaticJsonBuffer<200> jsonBuffer;

void setup()
{

  Serial.begin(115200);
  delay(10);

  lcd.begin(16, 2);
  delay(20);

  lcd.createChar(0, wifi1);
  lcd.createChar(1, wifi2);
  lcd.createChar(2, wifi3);

  // Print a message to the LCD.
  lcd.setCursor(0, 0);
  lcd.print("Starting up");

  // We start by connecting to a WiFi network
  WiFiMulti.addAP("networkname", "password");

  Serial.println();
  Serial.print("Wait for WiFi... ");

  lcd.setCursor(15, 0);
  lcd.write(byte(0));
  delay(200);
  lcd.setCursor(15, 0);
  lcd.write(byte(1));
  delay(200);
  lcd.setCursor(15, 0);
  lcd.write(byte(2));
  delay(200);
  lcd.setCursor(15, 0);
  lcd.write(byte(1));
  delay(200);
  lcd.setCursor(15, 0);
  lcd.write(byte(0));

  while(WiFiMulti.run() != WL_CONNECTED) {
      Serial.print(".");
      lcd.setCursor(15, 0);
      lcd.write(byte(0));
      delay(200);
      lcd.setCursor(15, 0);
      lcd.write(byte(1));
      delay(200);
      lcd.setCursor(15, 0);
      lcd.write(byte(2));
      delay(200);
      lcd.setCursor(15, 0);
      lcd.write(byte(1));
      delay(200);
  }

  Serial.println("");
  Serial.println("WiFi connected");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  Serial.println(WiFi.macAddress());

  delay(500);
}


void loop()
{

    // Use WiFiClient class to create TCP connections
    HTTPClient http;

    http.begin("http://io.adafruit.com/api/v2/estranged/feeds/mark-status/data/?limit=1&include=value"); //HTTP

    // start connection and send HTTP header
    int httpCode = http.GET();

    // httpCode will be negative on error
    if(httpCode > 0) {
        // HTTP header has been send and Server response header has been handled
        Serial.printf("[HTTP] GET... code: %d\n", httpCode);

        // file found at server
        if(httpCode == HTTP_CODE_OK) {
            String payload = http.getString();
            Serial.println(payload);

            jsonBuffer.clear();
            JsonArray& jsonArray = jsonBuffer.parseArray(payload);
            Serial.println(jsonBuffer.size());
            const char* statusValue = jsonArray[0]["value"];
            Serial.println(statusValue);
            String statusString = String(statusValue);

            int newLineIndex = statusString.indexOf("|");
            Serial.println(newLineIndex);
            String lineOne = statusString;
            String lineTwo;
            if (newLineIndex > 0) {
              lineOne = statusString.substring(0, newLineIndex);
              lineTwo = statusString.substring(newLineIndex + 1);
            }
            lcd.clear();
            lcd.setCursor(0, 0);
            lcd.print(lineOne);
            if (newLineIndex > 0) {
              lcd.setCursor(0, 1);
              lcd.print(lineTwo);
            }
        }
    } else {
        Serial.printf("[HTTP] GET... failed, error: %s\n", http.errorToString(httpCode).c_str());
    }

    http.end();

    delay(60000);

}
```




----

