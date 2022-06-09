// Soil Moisture Sensor 
// Reads sensor and desplays level and whether soil is wet or dry

// Water Threshold 
int threshold = 250;
// Setting the pin A0 on the Arduino to be our sensor
int soilPin = A0;
// Setting a variable for Soil moisture Power
int soilPower = 7;
// Setting up pump control from pin 9, a PWM capable pin
const int pumpPin = 9;

void setup(){
  // In void setup, initial functions needed for the rest of the program are run all at 
  // once before executing the rest of the code.
  //This command opens a serial to view the soil moisture sensor data in the serial monitor
  Serial.begin(9600); 
  pinMode(pumpPin, OUTPUT); //set pump control pin to be an output pin
  pinMode(soilPower, OUTPUT);//Set pin 7 as an OUTPUT pin
  digitalWrite(soilPower, LOW);//Set pin to LOW so no power is flowing through the sensor
}

void loop(){
  // Void loop allows the program to run continually based on initial values from void setup. 
  int sensorValue; // We are setting up a new variable, which will input the sensor value
  sensorValue = readSoil(); //this command inputs the sensor value from the sensor
   //Write what we want to display in the serial monitor:
  Serial.print("Moisture:");
  Serial.print(sensorValue); 
  String DisplayWords; //By defining a string, we are telling Arduino that the outputting message
  // will be letters, not numbers.
  
  // Now we are going to check if the water level is below the 
  // threshold value we set earlier, and if it is have 
  // word "DRY" displayed after the sensor value
  if (sensorValue <= threshold){

    DisplayWords = ",DRY \n";
    Serial.print(DisplayWords);
  // If the value is not below our threshold value we want to 
  // change the display words to "Wet, Leave it!"
  analogWrite(pumpPin, 150); // turn the pump on and set to a slow speed (0 is stopped, 255 is full speed)

  } else if (sensorValue >= threshold){

    DisplayWords = ",WET \n";
    Serial.print(DisplayWords);
    //turn pump off, to 0.
    analogWrite(pumpPin, 0);
  } 

}

//This is a function used to get the soil moisture content
int readSoil()
{
    digitalWrite(soilPower, HIGH);//turn D7 "On"
    delay(10);//wait 10 milliseconds 
    int val = analogRead(soilPin);//Read the SIG value form sensor 
    digitalWrite(soilPower, LOW);//turn D7 "Off"
    return val;//send current moisture value
}
