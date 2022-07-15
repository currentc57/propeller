/* **********************************************************************************************
*  Example program to plot sine wave data on MegunoLink's Time Plot visualiser. Find the 
*  MegunoLink project (Sinewave.mlpz), that goes with this example, in the same folder
*  as this Arduino code file.
* 
*  For more information:
*     Getting started with plotting:
*       https://www.megunolink.com/documentation/getting-started/plotting-data/
*     Time plot visualizer reference:
*       https://www.megunolink.com/documentation/plotting/time-plot/
*     Installing the MegunoLink Arduino library:
*       https://www.megunolink.com/documentation/getting-started/arduino-integration/
*     Sending data to multiple plots:
*       https://www.megunolink.com/documentation/plotting/sending-data-to-multiple-plots/
*  ********************************************************************************************** */
#include <megunolink_ez.h>

// Variable to send data to MegunoLink. For all the methods available,
// see: https://www.megunolink.com/documentation/plotting/time-plot-reference/
megunolink_ez meguno(Serial);

void setup()
{
  meguno.begin(115200);

  // Set titles for the plot and axis. These can also be edited 
  // in MegunoLink: https://www.megunolink.com/documentation/plotting/plot-properties/
  //MyPlot.SetTitle("Sine and Cosine Function Waveforms");
  meguno.writeTplotSet("title", "Sine and Cosine Waveforms");
  //MyPlot.SetXLabel("Time");
  meguno.writeTplotSet("x-label", "Time");
  //MyPlot.SetYLabel("Amplitude");
  meguno.writeTplotSet("y-label", "Amplitude");
  
  // Set the series styles. Styles can be sent along with data (see loop) and/or edited in MegunoLink:
  //   * Set series properties: https://www.megunolink.com/documentation/plotting/series-properties/
  //   * Set default series styles: https://www.megunolink.com/documentation/plotting/default-series-styles/
  // Here:
  //    * "Sinewave" = series name, 
  //    * Plot::Blue = line colour (e.g., Red, Green, Blue, Yellow, Black, Magenta, Cyan, White)
  //    * Plot::Solid = line style (e.g., Solid, Dashed, Dotted, DashDot, DashDotDot)
  //    * 2 = line width, 
  //    * Plot::Square = marker style (e.g., Square, Diamond, Triangle, Circle, Cross, Plus, Star, DownwardTriangle, NoMarker
  //MyPlot.SetSeriesProperties("Sinewave", Plot::Green, Plot::Solid, 2, Plot::Diamond);
  meguno.writeTplotStyle("Sinewave", 'b', 's', '_', 2);
  //MyPlot.SetSeriesProperties("Cosinewave", Plot::Red, Plot::Solid, 2, Plot::Square);
  meguno.writeTplotStyle("Cosinewave", 'r', 'd', ';', 2);

}


void loop()
{
  // Create some data to send. Here, a value from sine and cosine curves. 
  double dY, dY2;
  float seconds;
  float frequency = 0.5; //Hz
  float phase = 3.141/2;

  meguno.listen(); // WARNING: This function must be called repeatedly to response touch events
                       // from Nextion touch panel. Actually, you should place it in your loop function.

  seconds = (float)millis()/1000;
  Serial.println(seconds);
  
  dY = sin(2 * 3.141 * frequency * seconds);
  dY2 = cos(2 * 3.141 * frequency * seconds + phase);

  // Send Data To MegunoLink. See https://www.megunolink.com/documentation/plotting/time-plot-reference/#SendData2
  //MyPlot.SendData(F("Sinewave"), dY);
  meguno.writeTplotData("Sinewave", dY);

  // Send data to MegunoLink including optional series color (Red), line style (solid), 
  // line width (2) and marker style (Square). Series styles override current settings
  // in MegunoLink. 
  //MyPlot.SendData(F("Cosinewave"), dY2, Plot::Red, Plot::Solid, 2, Plot::Square);
  meguno.writeTplotData("Cosinewave", dY2);

  // Include a small delay (or send data periodically) to avoid overwhelming the serial
  // channel. See https://www.megunolink.com/documentation/arduino-libraries/arduino-timer/
  // for a straight forward method to send data periodically. 
  delay(10);
}
