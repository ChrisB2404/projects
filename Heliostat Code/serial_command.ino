/*
  Sample parsing code

  This code demonstrates how to parse commands from the serial line.
  1)When the user enters a line into the serial monitor, this code reads
  the first character. It uses a switch statement to call the appropriate
  function that corresponds to the first letter.
  2)The function that is called may need to parse addional parameters from
  the serial port. Use Serial.parseInt() or Serial.parseFloat() to read the
  needed parameters000000000000
  3)There will be a line return character, and possibly other unused characters
  waiting in the serial port. Call the purge routine to flush it out.
*/

//main function used to move the system by amount of steps:
//if axis is 1, rotate motor 1, if 2, rotate motor 2
//if rotation direction is 1, rotate counter clockwise
//if rotation direction is 0, rotate clockwise
//steps is just as inputted
//rpm is default set to 20 unless another value is input

#include <Arduino.h>
#include <stddef.h>
#include <EasyButton.h>
#include "BasicStepperDriver.h"
#include "Adafruit_SHTC3.h"
Adafruit_SHTC3 shtc3 = Adafruit_SHTC3();
#define MOTOR_STEPS 200
#define MICROSTEPS 1

//Pins for the limit switches
#define LIMONE 18
#define LIMTWO 23

int incomingByte = 0;
char inByte;
sensors_event_t humidity, temp;

//set base rpm, not used much in actual code as it usually updated to another value
int rpm = 20;

//direction and step pins for driver board one and two
int dirOne = 5;
int sOne = 17;
int dirTwo = 16;
int sTwo = 19;

//variable for gear ratio adjustments
int stepRatio = 4;
float moveRatio = 4.0;

//boolean values used in updating if the switch has been pressed
bool pressedTwo = false;
bool pressedOne = false;

//// variables used to count steps of motor
int motorStepsOne = 0;
int motorStepsTwo = 0;
int stepsLeftOne = 0;
int stepsLeftTwo = 0;
float motorAngleOne = 0.0;
float motorAngleTwo = 0.0;
BasicStepperDriver stepperOne(MOTOR_STEPS, dirOne, sOne);
BasicStepperDriver stepperTwo(MOTOR_STEPS, dirTwo, sTwo);
EasyButton buttonTwo(LIMTWO);
EasyButton buttonOne(LIMONE);

void buttonPressedTwo()
{
  Serial.println("Button Two pressed");
  //stepsLeftTwo = (int)stepperTwo.stop();

  //Serial.println(stepsLeftTwo);
  pressedTwo = true;
}

void buttonPressedOne()
{
  Serial.println("Button One pressed");
  //stepsLeftOne = (int)stepperOne.stop();
  pressedOne = true;
}

void buttonISRTwo()
{
  buttonTwo.read();
}

void buttonISROne()
{
  buttonOne.read();
}

float degCalculator(float degree)
{
  int temp =(int)(degree * 100);
  //Serial.print("New value One: "); Serial.println(temp);
  int tempm = temp%45;
  //Serial.print("New value Two: "); Serial.println(tempm);
  float tempf = ((float)temp)/100;
  //Serial.print("New value Three: "); Serial.println(tempf);
  float tempmf = ((float)tempm)/100;
  //Serial.print("New value Four: "); Serial.println(tempmf);
  return tempf - tempmf;
}

void setup() {
  // Open serial communications and wait for port to open:
  Serial.begin(115200);
  stepperOne.begin(rpm, MICROSTEPS);
  stepperTwo.begin(rpm, MICROSTEPS);
  buttonTwo.begin();
  buttonOne.begin();
  buttonTwo.onPressedFor(50, buttonPressedTwo);
  buttonOne.onPressedFor(50, buttonPressedOne);
  if (buttonTwo.supportsInterrupt())
  {
    buttonTwo.enableInterrupt(buttonISRTwo);
    Serial.println("Button will be used through interrupts");
  }
  if (buttonOne.supportsInterrupt())
  {
    buttonOne.enableInterrupt(buttonISROne);
    Serial.println("Button will be used through interrupts");
  }
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB port only
  }

  // send an intro:
  Serial.println("Homing ....");  delay(1000);
  Serial.println("Homing ....");  delay(1000);
  Serial.println("Homing ....");  delay(1000);

  Serial.println("Finished.");
  Serial.println("Awaiting your command.");

  Serial.println("SHTC3 test");
  if (! shtc3.begin()) {
    Serial.println("Couldn't find SHTC3");
    while (1) delay(1);
  }
  Serial.println("Found SHTC3 sensor");
}

//disregard this function for now
void CheckOne(int rot)
{
  if (pressedOne)
  {
    //   motorStepsOne = motorStepsOne - (rot * stepsLeftOne);
    Serial.print("Steps left One: ");
    Serial.println(stepsLeftOne);
    Serial.print("New steps One: ");
    Serial.println(motorStepsOne);
    pressedOne = false;
  }
}

//disregard this function for now
void CheckTwo(int rot)
{
  if (pressedTwo)
  {
    //    motorStepsTwo = motorStepsTwo - (rot * stepsLeftTwo);
    Serial.print("Steps left Two: ");
    Serial.println(stepsLeftTwo);
    Serial.print("New steps Two: ");
    Serial.println(motorStepsTwo);
    pressedTwo = false;
  }
}

//main function used to move the system by amount of steps:
//if axis is 1, rotate motor 1, if 2, rotate motor 2
//if rotation direction is 1, rotate counter clockwise
//if rotation direction is 0, rotate clockwise
//steps is just as inputted
//rpm is default set to 20 unless another value is input
int Step(int axis, int rot, int steps, int rpm = 20) {
  if (axis == 1)
  {
    stepperOne.setRPM(rpm);
    if (rot == 1)
    {
      //motorStepsOne = motorStepsOne + steps;
      //Serial.println("I'n in One");


      stepperOne.move(steps * stepRatio * MICROSTEPS);


      //Serial.print("Current One Steps: ");
      //Serial.println(motorStepsOne);
      //CheckOne();
    }
    else
    {
      //Serial.println("I'n in Two");
      //motorStepsOne = motorStepsOne - steps;


      stepperOne.move(-1 * steps * stepRatio * MICROSTEPS);


      //Serial.print("Current One Steps: ");
      //Serial.println(motorStepsOne);
      //CheckOne();
    }
  }
  else if (axis = 2)
  {
    stepperTwo.setRPM(rpm);
    if (rot == 1)
    {
      //motorStepsTwo = motorStepsTwo + steps;
      //Serial.println("I'n in Three");


      stepperTwo.move(steps * stepRatio * MICROSTEPS);


      //Serial.print("Current Two Steps: ");
      //Serial.println(motorStepsTwo);
      //CheckTwo(1);
    }
    else
    {
      //Serial.println("I'n in Four");
      //motorStepsTwo = motorStepsTwo - steps;


      stepperTwo.move(-1 * steps * stepRatio * MICROSTEPS);


      //Serial.print("Current Two Steps: ");
      //Serial.println(motorStepsTwo);
      //CheckTwo(-1);
    }
  }
  else
  {
    Serial.println("Error: Invalid command");
  }

}

//main command for moving motors via angles in degrees
//three inputs, which motor (1 or 2), 0 to 360 degrees, and then rpm
int Move(int axis, float angle, int rpm = 20) {
  float modifiedAngle = degCalculator(angle);
  if (axis == 1)
  {
    stepperOne.setRPM(rpm);
    motorStepsOne = motorStepsOne + stepperOne.calcStepsForRotation(angle);
    //Serial.println("I'n in One");


    stepperOne.rotate((modifiedAngle - motorAngleOne) * moveRatio);
    motorAngleOne = modifiedAngle;

  }
  else if (axis = 2)
  {
    stepperTwo.setRPM(rpm);
    motorStepsTwo = motorStepsTwo + stepperTwo.calcStepsForRotation(angle);
    //Serial.print("Motor 2 Steps Calculated from Angle: ");
    //Serial.println(stepperTwo.calcStepsForRotation(angle));
    //Serial.println("I'n in Three");


    stepperTwo.rotate((modifiedAngle - motorAngleTwo) * moveRatio);
    motorAngleTwo = modifiedAngle;

    //CheckTwo();
  }
  else
  {
    Serial.println("Error: Invalid command");
  }

}
int Home() {
  int temp = 0;

  //homing first motor
  while (pressedOne != true && temp <= 1000)
  {
    Step(1, 0, 1, 20);
    delay(6);
    buttonOne.update();
    temp = temp + 5;
  }
  if (temp > 1000)
  {
    Serial.println("Switch One not found!");
    temp = 0;
  }
  else
  {
    pressedOne = false;
    Step(1, 1, 7, 15);
    temp = 0;
    while (pressedOne != true)
    {
      Step(1, 0, 1, 5);
      delay(6);
      buttonOne.update();
    }
    Step(1, 1, 4, 15);
    motorAngleOne = (15 * 360 / (200 * moveRatio));
    pressedOne = false;
  }

  //homing second motor
  while (pressedTwo != true && temp <= 1000)
  {
    Step(2, 0, 1, 20);
    delay(6);
    buttonTwo.update();
    temp = temp + 5;
  }
  if (temp > 1000)
  {
    Serial.println("Switch Two not found!");
    temp = 0;
  }
  else
  {
    pressedTwo = false;
    Step(2, 1, 7, 15);
    temp = 0;
    while (pressedTwo != true)
    {
      Step(2, 0, 1, 5);
      delay(6);
      buttonTwo.update();
    }
    Step(2, 1, 4, 15);
    motorAngleTwo = (15 * 360 / (200 * moveRatio));
    pressedTwo = false;
  }
}

void purge() {
  delay(500);
  while (Serial.available() > 0) {
    // read the incoming byte:
    incomingByte = Serial.read();
  }
}

//overall function that gets called when program passes setup
void serialSwitch() {
  if (Serial.available() > 0) {
    // setting variables for later
    char c;
    int axis;
    int steps;
    int rotation = 0;
    float angle = 0.0;
    float azimuth = 0.0;
    float elevation = 0.0;
    String tempString = "";



    String input = Serial.readString();
    c = input.charAt(0);

    //    if (thisChar >= 97 && thisChar <= 122) {
    //      thisChar = thisChar - 32;
    //      Serial.print("Character: ");
    //      inByte = (char)thisChar;
    //      Serial.println((char)inByte);
    //         }

    switch (c) {
      case 'H':
      case 'h':
        Home();
        break;
      case 'S':
      case 's':
        //Setting the axis and rotation from the string
        axis = input.substring(2, 3).toInt();
        rotation = input.substring(4, 5).toInt();

        //Code for getting the amount of steps
        for (int i = 6; i < input.length(); i++)
        {
          if (input.charAt(i) == '\n')
          {
            // save integer to steps variable
            steps = tempString.toInt();
            //reset the temporary variable
            tempString = "";

            //check for errors in converting
            if (steps == 0)
            {
              Serial.println("Error converting to integer: no steps inputted");
            }
            break;

          }
          else if (input.charAt(i) == ' ')
          {
            steps = tempString.toInt();
            //reset the temporary variable
            tempString = "";

            //check for errors in converting
            if (steps == 0)
            {
              Serial.println("Error converting to integer: no steps inputted");
            }
            for (int j = i + 1; j < input.length(); j++)
            {
              if (input.charAt(j) == '\n')
              {
                // save integer to steps variable
                rpm = tempString.toInt();
                //reset the temporary variable
                tempString = "";

                //check for errors in converting
                if (rpm == 0)
                {
                  Serial.println("Error converting to int: no rpm inputted");
                }
                break;

              }
              // add current character to temporary string
              tempString.concat(input.charAt(j));
            }
            break;
          }
          // add current character to temporary string
          tempString.concat(input.charAt(i));

        }
        Serial.print("Axis of rotation: ");
        Serial.println(axis);
        Serial.print("Direction of rotation: ");
        Serial.println(rotation);
        Serial.print("Steps for rotation: ");
        Serial.println(steps);
        Serial.print("RPM: ");
        Serial.println(rpm);
        Step(axis, rotation, steps, rpm);

        break;
      case 'M':
      case 'm':
        //Setting the axis and rotation from the string
        axis = input.substring(2, 3).toInt();
        //rotation = input.substring(4, 5).toInt();
        Serial.print("Length: "); Serial.println(input.length());
        //Code for getting the amount of steps
        for (int i = 4; i < input.length(); i++)
        {
          if (input.charAt(i) == '\n')
          {
            // save integer to steps variable
            angle = tempString.toFloat();
            //reset the temporary variable
            tempString = "";

            //check for errors in converting
            if (angle == 0.0)
            {
              Serial.println("Error converting to float: no steps inputted");
            }
            break;

          }
          else if (input.charAt(i) == ' ')
          {
            angle = tempString.toFloat();
            //reset the temporary variable
            tempString = "";

            //check for errors in converting
            if (angle == 0.0)
            {
              Serial.println("Error converting to integer: no steps inputted");
            }
            for (int j = i + 1; j < input.length(); j++)
            {
              if (input.charAt(j) == '\n')
              {
                // save integer to steps variable
                rpm = tempString.toInt();
                //reset the temporary variable
                tempString = "";

                //check for errors in converting
                if (rpm == 0)
                {
                  Serial.println("Error converting to int: no rpm inputted");
                }
                break;

              }
              // add current character to temporary string
              tempString.concat(input.charAt(j));
            }
            break;
          }
          // add current character to temporary string
          tempString.concat(input.charAt(i));

        }
        Serial.print("Axis of rotation: ");
        Serial.println(axis);
        Serial.print("Direction of rotation: ");
        Serial.println(rotation);
        Serial.print("Degrees for rotation: ");
        Serial.println(angle);
        Serial.print("RPM: ");
        Serial.println(rpm);
        Move(axis, angle, rpm);
        break;
      case 'A':
        for (int i = 2; i < input.length(); i++)
        {
          if (input.charAt(i) == '\n')
          {
            // save integer to steps variable
            azimuth = tempString.toFloat();
            //reset the temporary variable
            tempString = "";

            //check for errors in converting
            if (azimuth == 0.0)
            {
              Serial.println("Error converting to float: no steps inputted");
            }
            break;

          }
          // add current character to temporary string
          tempString.concat(input.charAt(i));
        }
        Serial.print("Azimuth angle: ");
        Serial.println(azimuth);
        Serial.println("Azimuth not implemented yet.");
        break;
      case 'E':
        for (int i = 2; i < input.length(); i++)
        {
          if (input.charAt(i) == '\n')
          {
            // save integer to steps variable
            elevation = tempString.toFloat();
            //reset the temporary variable
            tempString = "";

            //check for errors in converting
            if (elevation == 0.0)
            {
              Serial.println("Error converting to float: no steps inputted");
            }
            break;

          }
          // add current character to temporary string
          tempString.concat(input.charAt(i));
        }
        Serial.print("Elevation angle: ");
        Serial.println(elevation);
        Serial.println("Elevation not implemented yet.");
        break;
      case 'P': Serial.println("This is the Power Down stub."); break;
      case 'T':
      case 't':
        shtc3.getEvent(&humidity, &temp);
        Serial.print("Temperature: "); Serial.print(temp.temperature); Serial.println(" degrees C");
        Serial.print("Humidity: "); Serial.print(humidity.relative_humidity); Serial.println("% rH");
        break;
      case 'D': Move(2, 179, 15); Serial.println("Moved to Safety"); break;
      default :
        Serial.println("I don't even know what that was supposed to be.");
        break;
    }
    purge(); //remove any extra characters in the queue (like return)

    Serial.println("Waiting your command.");
  }
}

void loop() {
  // get any incoming bytes:
  serialSwitch();

}
