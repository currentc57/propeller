/* ***********************************************************************************************
*  Example demonstrating MegunoLink's interface panel visualizer and Arduino command handler. 
*  It extends the classic Arduino Blink example with serial commands to control the flash rate. 
*  Find the MegunoLink project (Blink2.mlpz), that goes with this example, in the same folder as
*  this Arduino code file. 
* 
*  You'll need to install MegunoLink's Arduino library to use this example:
*       https://www.megunolink.com/documentation/getting-started/arduino-integration/
*
*  For more information:
*     Getting started building Arduino interfaces
*       https://www.megunolink.com/documentation/getting-started/build-arduino-interface/
*     Getting started processing serial commands
*       https://www.megunolink.com/documentation/getting-started/processing-serial-commands/
*     Interface panel reference
*       https://www.megunolink.com/documentation/interface-panel/
* 
*  The following serial commands are supported:
*       !onTime n\r\n
*         Sets the amount of time the LED remains on to n [milliseconds]
* 
*       !OffTime n\r\n
*         Sets the amount of time the LED remains off to n [milliseconds]
* 
*       !ListAll\r\n
*         Lists current blink parameters & sends them to the interface panel. 
*
* *********************************************************************************************** */

#include <megunolink_ez.h>

/// <summary>
/// Variables that control the blink interval and keep track of when we blinked. 
/// </summary>
long lastBlink = 0; // Time we last blinked the LED
int onTime = 10;    // Amount of time the LED remains on [milliseconds]
int offTime = 100;  // Amount of time the LED remains off [milliseconds]
int temp = 0;

/// <summary>
/// The command handler looks after parsing and dispatching serial commands to Arduino functions
/// </summary>
//CommandHandler<> SerialCommandHandler;
megunolink_ez meguno(Serial);

/// <summary>
/// Called when the 'onTime' command is received to set the time the LED remains on. 
/// </summary>
/// <param name="Parameters">Contains new on-time (in milliseconds)</param>
void setOn(){
  onTime = meguno.readInt(F("numOnTime.Value"));
}

/// <summary>
/// Called when the 'OffTime' command is received to set the time the LED remains off. 
/// </summary>
/// <param name="Parameters">Contains new off-time (in milliseconds)</param>
void setOff(){
  offTime = meguno.readInt(F("numOffTime.Value"));
}

/// <summary>
/// Called when the 'ListAll' command is received
/// </summary>
/// <param name="Parameters">No parameters</param>
void listAll(){
  // Write current timing to serial stream
  Serial.print(F("onTime [ms]="));
  Serial.println(onTime);
  Serial.print(F("OffTime [ms]="));
  Serial.println(offTime);

  // Send timing to interface panel. 
  meguno.writeNum(F("numOnTime.Value"), onTime);
  meguno.writeNum(F("numOffTime.Value"), offTime);  
}

void setup() 
{
  Serial.begin(9600);
  Serial.println(F("Blink 2.0"));
  Serial.println(F("=========="));
  meguno.begin(9600);

  pinMode(LED_BUILTIN, OUTPUT);
}

void loop() 
{
  // Check for serial commands and dispatch them to registered functions.
  //SerialCommandHandler.Process();
  meguno.listen(); // WARNING: This function must be called repeatedly to response touch events
                         // from Nextion touch panel. Actually, you should place it in your loop function.
  if (meguno.cmdAvail()) {
    readCommand(meguno.getCmd());
  }
  
  // Update the LED
  uint32_t uNow = millis();
  if ( (uNow - lastBlink) < onTime)
  {
    digitalWrite(LED_BUILTIN, HIGH);
  }
  else
  {
    digitalWrite(LED_BUILTIN, LOW);
  }

  if ( (uNow - lastBlink) > (onTime + offTime) )
  {
    lastBlink = uNow;
  }
}

void readCommand(const int32_t cmd) {
    switch (cmd) {
    case 'T' :
        callTrigger(meguno.readByte());
        break;   
    default:
        break;
    }
}

void callTrigger(const int32_t trig) {
    switch (trig) {
    case 0x00 :
        listAll();
        break;
    case 0x01 :
        setOn();
        break;
    case 0x02 :
        setOff();
        break;
    default:
        break;
    }
}
