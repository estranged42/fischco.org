/*
 * Twinkling LEDs
 *
 * Using PWM from TLC5940, twinkle a number of LEDs to immitate a star field
 *
 * Mark Fischer
 * estranged [at] mac [dot] com
 * http://www.fischco.org


    Basic Pin setup:
    ------------                                  ---u----
    ARDUINO   13|-> SCLK (pin 25)           OUT1 |1     28| OUT channel 0
              12|                           OUT2 |2     27|-> GND (VPRG)
              11|-> SIN (pin 26)            OUT3 |3     26|-> SIN (pin 11)
              10|-> BLANK (pin 23)          OUT4 |4     25|-> SCLK (pin 13)
               9|-> XLAT (pin 24)             .  |5     24|-> XLAT (pin 9)
               8|                             .  |6     23|-> BLANK (pin 10)
               7|                             .  |7     22|-> GND
               6|                             .  |8     21|-> VCC (+5V)
               5|                             .  |9     20|-> 2K Resistor -> GND
               4|                             .  |10    19|-> +5V (DCPRG)
               3|-> GSCLK (pin 18)            .  |11    18|-> GSCLK (pin 3)
               2|                             .  |12    17|-> SOUT
               1|                             .  |13    16|-> XERR
               0|                           OUT14|14    15| OUT channel 15
    ------------                                  --------

    -  Put the longer leg (anode) of the LEDs in the +5V and the shorter leg
         (cathode) in OUT(0-15).
    -  +5V from Arduino -> TLC pin 21 and 19     (VCC and DCPRG)
    -  GND from Arduino -> TLC pin 22 and 27     (GND and VPRG)
    -  digital 3        -> TLC pin 18            (GSCLK)
    -  digital 9        -> TLC pin 24            (XLAT)
    -  digital 10       -> TLC pin 23            (BLANK)
    -  digital 11       -> TLC pin 26            (SIN)
    -  digital 13       -> TLC pin 25            (SCLK)
    -  The 2K resistor between TLC pin 20 and GND will let ~20mA through each
       LED.  To be precise, it's I = 39.06 / R (in ohms).  This doesn't depend
       on the LED driving voltage.
    - (Optional): put a pull-up resistor (~10k) between +5V and BLANK so that
                  all the LEDs will turn off when the Arduino is reset.

    If you are daisy-chaining more than one TLC, connect the SOUT of the first
    TLC to the SIN of the next.  All the other pins should just be connected
    together:
        BLANK on Arduino -> BLANK of TLC1 -> BLANK of TLC2 -> ...
        XLAT on Arduino  -> XLAT of TLC1  -> XLAT of TLC2  -> ...
    The one exception is that each TLC needs it's own resistor between pin 20
    and GND.

    This library uses the PWM output ability of digital pins 3, 9, 10, and 11.
    Do not use analogWrite(...) on these pins.

    This sketch does the Knight Rider strobe across a line of LEDs.

    Alex Leone <acleone ~AT~ gmail.com>, 2009-02-03

 */

/**
 * Uses the wonderful TLC5940 library by acleone
 * http://www.arduino.cc/playground/Learning/TLC5940
 * http://code.google.com/p/tlc5940arduino/
 */
#include "Tlc5940.h"

/**
 * Use timed actions
 * @url http://www.arduino.cc/playground/Code/TimedAction
 */
#include <TimedAction.h>

#define UP 1
#define DOWN 0

/**
 * How many LEDs are hooked up. 
 * If chaining multiple TLC5940 chips together, 
 * this should be a multiple of 16
 */
#define NUM_LEDS 32

/**
 * How long to wait before picking a new LED to twinkle.
 * Smaller values result in more LEDs being lit at once.
 */
#define TWINKLE_SPACING 20

/**
 * The maximum brightness allowed.
 */
#define MAX_BRIGHTNESS 512

int led_brightness[NUM_LEDS];
int led_direction[NUM_LEDS];
int led_speed[NUM_LEDS];
int twinkle_spacing = TWINKLE_SPACING;
int min_speed;
int max_speed;

const int BLINK_MODE_TWINKLE = 1;
const int BLINK_MODE_ALL_ON = 2;
int blink_mode = BLINK_MODE_ALL_ON;

 /**
  * Setup our timed action for changing modes
  */
  TimedAction delay_twinkle = TimedAction(NO_PREDELAY,5000,twinkle_start);

void setup()
{
 /**
  * Pick a minimum and maximum speed.  Scale with the max brightness.
  * We can't let the speeds be zero, so set some lower limits.
  */
 min_speed = MAX_BRIGHTNESS / 500;
 max_speed = MAX_BRIGHTNESS / 50;
 if (min_speed < 1) {
   min_speed = 1;
 }
 if (max_speed < 3) {
   max_speed = 3;
 }

 /**
  * Initialize the brightness, direction, and speed arrays
  */
 int i = 0;
 for (i = 0 ; i < 3 ; i++) {
   led_brightness[i] = 0;
   led_direction[i] = DOWN;
   led_speed[i] = min_speed;
 }
 
 /**
  * Initialize the TLC library
  */
 Tlc.init();
 
 /**
  * Seed the random number generator
  */
 randomSeed(analogRead(0));

}

void loop()
{
  switch(blink_mode) {
    case BLINK_MODE_TWINKLE:
      // pick a new LED every so often
      if (twinkle_spacing == 0) {
        random_led();
        twinkle_spacing = TWINKLE_SPACING;
      } else {
        twinkle_spacing--;
      }

      twinkle();

      // wait a bit between each twinkle cycle.  
      // Increase this to stretch out things if everything twinkles too fast.
      delay(20);
      break;
    
    case BLINK_MODE_ALL_ON:
      // check to see if we should switch to twinkle mode
      delay_twinkle.check();
      all_on();
      delay(20);
      break; 
  }
   
}

/**
 * For each of our LEDs, we update their brightness
 */
void twinkle() {
  int brightness;
  int dir;
  int rate;
  
  int i = 0;
  for (i = 0 ; i < NUM_LEDS ; i++) {
    
    brightness = led_brightness[i];
    dir = led_direction[i];
    rate = led_speed[i];
    
    Tlc.set(i, brightness);
    
    /**
     * Pick new values for the next twinkle cycle.
     */
    if (dir == DOWN) {
      brightness -= rate;
      if (brightness <= 0) {
        brightness = 0;
      }
    }

    if (dir == UP) {
      brightness += rate;
      if (brightness >= MAX_BRIGHTNESS) {
        dir = DOWN;
        brightness = MAX_BRIGHTNESS;
      }
    }
    
    /**
     * Update the LED arrays with the new values for next twinkle cycle.
     */ 
    led_brightness[i] = brightness;
    led_direction[i] = dir;
  }
  
  Tlc.update();

}

/**
 * Pick a new LED that isn't already twinkling, and give it a 
 * random speed to twinkle at.  It will be updated next twinkle() call.
 */
void random_led() {
  // pick a random LED
  int led = random(NUM_LEDS);
  
  // if that one isn't twinkling already, go!
  if (led_direction[led] == 0 && led_brightness[led] == 0) {
    led_direction[led] = UP;
    led_speed[led] = random(min_speed, max_speed);
  }
}

/**
 * Turn all the LEDs on at some value
 */
void all_on() {
  int i = 0;
  for (i = 0 ; i < NUM_LEDS ; i++) {
     Tlc.set(i, 256);
  }
  Tlc.update();
  
}

/**
 * Change the program mode from all on to twinkle
 */
void twinkle_start()
{
  blink_mode = BLINK_MODE_TWINKLE;
  // stop the timed action so it doesn't fire again needlessly
  delay_twinkle.disable();
}
