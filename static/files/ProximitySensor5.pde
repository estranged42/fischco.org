/**
 * Proximity Sensor
 * Version 5
 * Mark Fischer
 * estranged@mac.com
 *
 * Uses an ultrasonic sensor to detect if something is within range or not.
 *
 * Two buttons are used to adjust the set point, defining the distance at which
 * something is decided to be within range or not.
 *
 * When the state changes from AWAY to HERE, or HERE to AWAY, a serial message
 * is sent to the computer.
 *
 * Version 5
 * Adding an array to smooth out the input fluctuations
 *
 */

#define AWAY 0
#define HERE 1

// Setup our ultrasonic sensor pin. This is an analog pin
int sensorValue = 255;
int sensorPin = 1;

// Define our LED pin.  Digital pin 15 is analog pin 1
int ledPin = 14;

// Define our button pins
int upPin = 10;
int downPin = 11;

// variables to track if the Up button is being pressed or not
int lastUpState;
int currentUpState;

// variables to track if the Down button is being pressed or not
int lastDownState;
int currentDownState;

// the range set point
int setPoint;

// initialize our current state and last read values
int curState = AWAY;
int lastStateRead = LOW;

// an array to hold a bunch of sensor values for an average
int sampleSize = 99; // n readings 0 .. (n - 1)
int sensorReadings[100]; // 10 readings, 0 .. n
int sampleCount = 0;

// a delay to stop rapid here/away msgs when its borderline
int delayBuffer = 0;

void setup()
{
  Serial.begin(9600);
  
  // setup our LED pin, and turn it off
  pinMode(ledPin, OUTPUT);
  digitalWrite(ledPin, LOW);
  
  // set our Up pin to input
  pinMode(upPin, INPUT);
  // turn on internal Pull-Up resistor
  digitalWrite(upPin, HIGH);
  
  // set our Down pin to input
  pinMode(downPin, INPUT);
  // turn on internal Pull-Up resistor
  digitalWrite(downPin, HIGH);
  
  // set our inital setPoint to something
  setPoint = 50;
  
  // init out our sensorReadings array
  int i;
  for (i = 0; i < sampleSize; i++) {
    sensorReadings[i] = setPoint;
  }
}

void loop() {
  delay(10);
  
  /**
   * Detect if something is in range or not.
   */
  sensorValue = analogRead(sensorPin);
  
  // store the current value in our readings array
  sensorReadings[sampleCount] = sensorValue;
  
  // sampleCount starts life at 0, then loops through sampleSize
  if (sampleCount == sampleSize) {
    sampleCount = 0;
  } else {
    sampleCount++;
  }
  
  // figure out the average sensor value
  int i;
  int sensorSum = 0;
  int averageValue = 0;
  for (i = 0; i < sampleSize; i++) {
    // Serial.print(sensorReadings[i]);
    // Serial.print(", ");
    sensorSum = sensorSum + sensorReadings[i];
  }
  averageValue = sensorSum / sampleSize;
/*
Serial.print(" Cur: ");
Serial.print(sensorValue);
Serial.print("   Count: ");
Serial.print(sampleCount);
Serial.print("   Sum: ");
Serial.print(sensorSum);
Serial.print("   Size: ");
Serial.print(sampleSize);
Serial.print("   Avg: ");
Serial.println(averageValue);
*/

  // decriment the delay buffer if needed
  if (delayBuffer > 0) {
    delayBuffer--;
  }

  if (averageValue < setPoint) {
    if (lastStateRead == HIGH) {
      if (curState == AWAY && delayBuffer == 0) {
        setHere();
      }
    } else {
      lastStateRead = HIGH;
    }
  } else {
    if (lastStateRead == LOW) {
      if (curState == HERE && delayBuffer == 0) {
        setAway();
      }
    } else {
      lastStateRead = LOW;
    }
  }
  
  
  /**
   * Detect Button Presses
   */
   
  // check to see if the up button was pressed
  currentUpState = digitalRead(upPin);
  
  if (currentUpState != lastUpState) {
    if (currentUpState == LOW) {
      // button depressed
      updateSetPoint(1);
    }
    delay(50);
  }
  
  lastUpState = currentUpState;
  
  // check to see if the down button was pressed
  currentDownState = digitalRead(downPin);
  
  if (currentDownState != lastDownState) {
    if (currentDownState == LOW) {
      // button depressed
      updateSetPoint(-1);
    }
    delay(50);
  }
  
  lastDownState = currentDownState;

}

void setHere() {
  curState = HERE;
  digitalWrite(ledPin, HIGH);
  Serial.print(1, DEC);
  // Serial.println("HERE");
  delay(40);
  delayBuffer = 800;
}

void setAway() {
  curState = AWAY;
  digitalWrite(ledPin, LOW);
  Serial.print(0, DEC);
  // Serial.println("AWAY");
  delay(40);
  delayBuffer = 800;
}

void updateSetPoint(int incriment) {
  setPoint = setPoint + incriment;
  Serial.print("Set Point: ");
  Serial.println(setPoint);
}
