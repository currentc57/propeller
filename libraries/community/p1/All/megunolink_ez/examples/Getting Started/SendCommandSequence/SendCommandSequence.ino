/************************************************************************************************
== Example Description ==
This code helps demonstrate MegunoLink's message monkey visualizer, which lets MegunoLink send
a series of commands to your Arduino sketch. In this example MegunoLink sends commands to 
turn on and off a digital output. 

== This Example Requires ==
* MegunoLink's Arduino library. Install it from MegunoLink by selecting 'Setup Arduino integration' 
  from the gear menu.

== More Information ==
* Download a free trial of MegunoLink: https://www.megunolink.com/download/
* Setup Arduino integration: https://www.megunolink.com/documentation/getting-started/arduino-integration/
* Serial command handler: https://www.megunolink.com/documentation/arduino-libraries/serial-command-handler/

== MegunoLink Interface ==
* Open the MegunoLink interface by selecting 'Send Command Sequence' from MegunoLink's 
  Examples->Getting Started menu. 
 
== Serial Commands ==
This sketch implements the following serial commands:
* !Out <State> <Port>\r\n : Turns a digital output state. Port is the pin number to change. The
  output is turned on when State is 1 and off when state is 0. Port defaults to the built-in
  LED if it is missing. 

************************************************************************************************/

#include <megunolink_ez.h>

// The serial command handler. Receives serial data and dispatches 
// recognised commands to functions registered during setup. 
megunolink_ez meguno(Serial);

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
        out();
        break;
    default:      
        break;
    }
}

// -----------------------------------------------------------------------
// Command handlers. 
// These functions are called when a serial command is received. 
void out(){
  int32_t State = 0;
  int Port = LED_BUILTIN;
  State = meguno.readByte();

  pinMode(Port, OUTPUT);
  digitalWrite(Port, State);
}

// -----------------------------------------------------------------------
void setup(){
  Serial.begin(9600);
  Serial.println(F("MegunoLink Output Controller"));
  Serial.println(F("----------------------------"));
  meguno.begin(9600); 
}

void loop()
{
  // Call the serial command handler's process function. It will receive
  // the serial data and call the registered function when a 
  // recognized command is received. 
  meguno.listen(); // WARNING: This function must be called repeatedly to response touch events
                         // from Nextion touch panel. Actually, you should place it in your loop function.
  if (meguno.cmdAvail()) {
    readCommand(meguno.getCmd());
  }
}
