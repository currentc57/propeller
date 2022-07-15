/* **********************************************************************************************
*  Example program to send data to a MegunoLink property table. Find the MegunoLink project 
*  (Sinewave.mlpz), that goes with this exaple, in the same folder as this Arduino code file.
* 
*  For more information:
*    Property table visualizer reference:
*      https://www.megunolink.com/documentation/table/property-table/
*    Installing the MegunoLink Arduino library:
*      https://www.megunolink.com/documentation/getting-started/arduino-integration/
*  ********************************************************************************************** */

#include <megunolink_ez.h>
#include "ArduinoTimer.h" // To periodically send data. 

// Progress value variables (the data we'll send)
int Fish, Turtles; 

// To send data to MegunoLink property tables. For all the methods available, see:
// https://www.megunolink.com/documentation/table/sending-data-to-the-property-table/
megunolink_ez meguno(Serial);

// To keep track of when we should send data. 
// See: https://www.megunolink.com/documentation/arduino-libraries/arduino-timer/
ArduinoTimer SendTimer;

void setup()
{
  Serial.begin(9600);
  Serial.println(F("Send to Property Table example"));
  Serial.println(F("------------------------------"));
  meguno.begin(9600);
  
  // Initialize data we're going to send. 
  Fish = 0;
  Turtles = 0;

  // Add descriptions to the table. These can be included when sending data 
  // too (see loop). 
  //MyTable.SetDescription("Fish", "Lives in the sea");
  //MyTable.SetDescription("Turtles", "Very slow");
}

void loop()
{
  // Check for serial commands and dispatch them to registered functions.
  //SerialCommandHandler.Process();
  meguno.listen(); // WARNING: This function must be called repeatedly to response touch events
                         // from Nextion touch panel. Actually, you should place it in your loop function.
  /*if (meguno.cmdAvail()) {
    readCommand(meguno.getCmd());
  }*/
  
  if (SendTimer.TimePassed_Milliseconds(1000))
  {
    // Send values to MegunoLink table. 
    //MyTable.SendData("Fish", Fish);
    meguno.writePtNum("Fish", Fish);

    // The description can be included too
    //MyTable.SendData("Turtles", Turtles, "Very slow");
    meguno.writePtNum("Turtles", Turtles);
    meguno.writePtDesc("Turtles", "Very slow");

    // Update the data we're sending. 
    Fish += 3;
    Turtles += 1;
  }
}
