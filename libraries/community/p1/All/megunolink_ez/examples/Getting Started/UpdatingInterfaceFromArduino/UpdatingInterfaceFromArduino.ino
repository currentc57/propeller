/* ***********************************************************************
 * Updating interface from Arduino
 * Example to illustrate changing control values in a MegunoLink interface
 * panel using commands sent from an Arduino sketch. 
 * 
 * Companion MegunoLink project: UpdatingInterfaceFromArduino.mlpz
 * 
 * For more information:
 *   Download MegunoLink trial: 
 *      https://www.MegunoLink.com/download/
 *   Getting started with interface panels:
 *      https://www.megunolink.com/documentation/getting-started/build-arduino-interface/
 *   Updating controls from your Arduino:
 *      https://www.megunolink.com/documentation/interface-panel/arduino-update-interface-panel/
 *   Control reference:
 *      https://www.megunolink.com/documentation/interface-panel/control-reference/
 * *********************************************************************** */

#include <megunolink_ez.h>

/// <summary>
/// Use InterfacePanel variables to send commands to controls on interface panels. 
/// Method reference: https://www.megunolink.com/documentation/interface-panel/interface-panel-arduino-reference/
/// </summary>
megunolink_ez meguno(Serial);

void setup()
{
  Serial.begin(9600);
  meguno.begin(9600);
}

void loop()
{
  // Set text displayed on controls
  meguno.writeStr(F("Item.Text"), F(""));
  meguno.writeStr(F("DescriptionTextbox.Text"), F(""));
  meguno.writeStr(F("DescriptionTextbox.Text"), F("Demo Starting"));
  delay(5000);
  meguno.writeStr(F("DescriptionTextbox.Text"), F(""));
  delay(500);
  meguno.writeStr(F("DescriptionTextbox.Text"), F("You can edit various controls from your arduino."));
  meguno.writeStr(F("Item.Text"), F("Including buttons,"));
  
  // Hide/show controls
  meguno.writeStr(F("MyButton.Visible"), F("false"));
  delay(500);
  meguno.writeStr(F("MyButton.Visible"), F("true"));
  delay(500);
  meguno.writeStr(F("MyButton.Visible"), F("false"));
  delay(500);
  meguno.writeStr(F("MyButton.Visible"), F("true"));
  delay(500);
  meguno.writeStr(F("MyButton.Visible"), F("false"));
  delay(500);
  meguno.writeStr(F("MyButton.Visible"), F("true"));
  delay(500);

  // Enable/disable controls
  meguno.writeStr(F("MyButton.Enabled"), F("false"));
  delay(500);
  meguno.writeStr(F("MyButton.Enabled"), F("true"));
  delay(500);
  meguno.writeStr(F("MyButton.Enabled"), F("false"));
  delay(500);
  meguno.writeStr(F("MyButton.Enabled"), F("true"));
  delay(500);
  meguno.writeStr(F("MyButton.Enabled"), F("false"));
  delay(500);
  meguno.writeStr(F("MyButton.Enabled"), F("true"));
  delay(500);

  // Change control colors
  meguno.writeStr(F("MyButton.ForeColor"), F("blue"));
  delay(500);
  meguno.writeStr(F("MyButton.ForeColor"), F("red"));
  delay(500);
  meguno.writeStr(F("MyButton.ForeColor"), F("green"));
  delay(500);
  meguno.writeStr(F("MyButton.ForeColor"), F("black"));
  delay(500);
  meguno.writeStr(F("MyButton.BackColor"), F("blue"));
  delay(500);
  meguno.writeStr(F("MyButton.BackColor"), F("red"));
  delay(500);
  meguno.writeStr(F("MyButton.BackColor"), F("green"));
  delay(500);
  meguno.writeStr(F("MyButton.BackColor"), F("white"));
  delay(500);


  // Update content of text boxes
  meguno.writeStr(F("Item.Text"), F("including buttons, textboxes"));
  delay(500);
  meguno.writeStr(F("MyTextbox.Text"), F("you"));
  delay(500);
  meguno.writeStr(F("MyTextbox.Text"), F("can"));
  delay(500);
  meguno.writeStr(F("MyTextbox.Text"), F("edit"));
  delay(500);;
  meguno.writeStr(F("MyTextbox.Text"), F("textboxes"));
  delay(500);
  meguno.writeStr(F("MyTextbox.Text"), F("from"));
  delay(500);
  meguno.writeStr(F("MyTextbox.Text"), F("your"));
  delay(500);
  meguno.writeStr(F("MyTextbox.Text"), F("arduino"));
  delay(500);


  // Update gauge values and labels
  meguno.writeStr(F("Item.Text"), F("including buttons, textboxes, gauges"));
  delay(500);
  meguno.writeStr(F("MyGauge.Label0"), F("you"));
  delay(500);
  meguno.writeStr(F("MyGauge.Label0"), F("can"));
  delay(500);
  meguno.writeStr(F("MyGauge.Label0"), F("edit"));
  delay(500);
  meguno.writeStr(F("MyGauge.Label0"), F("gauge"));
  delay(500);
  meguno.writeStr(F("MyGauge.Label0"), F("labels"));
  delay(500);
  meguno.writeStr(F("MyGauge.Label0"), F("from"));
  delay(500);
  meguno.writeStr(F("MyGauge.Label0"), F("your"));
  delay(500);
  meguno.writeStr(F("MyGauge.Label0"), F("arduino"));
  delay(500);
  meguno.writeNum(F("MyGauge.Value"), 100);
  delay(500);
  meguno.writeNum(F("MyGauge.Value"), 200);
  delay(500);
  meguno.writeNum(F("MyGauge.Value"), 300);
  delay(500);
  meguno.writeNum(F("MyGauge.Value"), 400);
  delay(500);
  meguno.writeNum(F("MyGauge.Value"), 500);
  delay(500);


  // Change checkboxes
  meguno.writeStr(F("Item.Text"), F("including buttons, textboxes, gauges, checkboxes"));
  delay(500);
  meguno.writeStr(F("MyCheckbox.Checked"), F("true"));
  delay(500);
  meguno.writeStr(F("MyCheckbox.Checked"), F("false"));
  delay(500);
  meguno.writeStr(F("MyCheckbox.Checked"), F("true"));
  delay(500);
  meguno.writeStr(F("MyCheckbox.Checked"), F("false"));
  delay(500);
  meguno.writeStr(F("MyCheckbox.Checked"), F("true"));
  delay(500);
  meguno.writeStr(F("MyCheckbox.Checked"), F("false"));
  delay(500);
  meguno.writeStr(F("MyCheckbox.Checked"), F("true"));
  delay(500);
  meguno.writeStr(F("MyCheckbox.Checked"), F("false"));
  delay(500);


  // Set value for trackbars
  meguno.writeStr(F("Item.Text"), F("trackbars"));
  delay(500);
  meguno.writeNum(F("MyTrackbar.Value"), 10);
  delay(500);
  meguno.writeNum(F("MyTrackbar.Value"), 20);
  delay(500);
  meguno.writeNum(F("MyTrackbar.Value"), 30);
  delay(500);
  meguno.writeNum(F("MyTrackbar.Value"), 40);
  delay(500);
  meguno.writeNum(F("MyTrackbar.Value"), 50);
  delay(500);


  // Set value for progress bars
  meguno.writeStr(F("Item.Text"), F("trackbars, progress bars"));
  delay(500);
  meguno.writeNum(F("MyProgressBar.Value"), 10);
  delay(500);
  meguno.writeNum(F("MyProgressBar.Value"), 20);
  delay(500);
  meguno.writeNum(F("MyProgressBar.Value"), 30);
  delay(500);
  meguno.writeNum(F("MyProgressBar.Value"), 40);
  delay(500);
  meguno.writeNum(F("MyProgressBar.Value"), 50);
  delay(500);


  // Control picture visibility
  meguno.writeStr(F("Item.Text"), F("trackbars, progress bars, pictures"));
  delay(500);
  meguno.writeStr(F("PausePicture.Visible"), F("false"));
  meguno.writeStr(F("PlayPicture.Visible"), F("true"));
  delay(500);
  meguno.writeStr(F("PausePicture.Visible"), F("true"));
  meguno.writeStr(F("PlayPicture.Visible"), F("false"));
  delay(500);
  meguno.writeStr(F("PausePicture.Visible"), F("false"));
  meguno.writeStr(F("PlayPicture.Visible"), F("true"));
  delay(500);
  meguno.writeStr(F("PausePicture.Visible"), F("true"));
  meguno.writeStr(F("PlayPicture.Visible"), F("false"));
  delay(500);
  meguno.writeStr(F("PausePicture.Visible"), F("false"));
  meguno.writeStr(F("PlayPicture.Visible"), F("true"));
  delay(500);
  meguno.writeStr(F("PausePicture.Visible"), F("true"));
  meguno.writeStr(F("PlayPicture.Visible"), F("false"));
  delay(500);


  meguno.writeStr(F("DescriptionTextbox.Text"), F("You can also have tab pages, value lists, radio buttons,"));
  meguno.writeStr(F("Item.Text"), F("group boxes, and buttons to launch files."));
  delay(10000);
}
