{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        TX = 30
        RX = 31
        LED = 16
        CR = $0A

VAR


OBJ
  meguno      : "megunolink_ez"

PUB main | timer

  meguno.start(RX, TX, 9_600)

  repeat
    'Set text displayed on controls
    meguno.uiSetStr(string("Item.Text"), string(" "))
    meguno.uiSetStr(string("DescriptionTextbox.Text"), string(" "))
    meguno.uiSetStr(string("DescriptionTextbox.Text"), string("Demo Starting"))
    waitcnt(clkfreq * 5 + cnt)
    meguno.uiSetStr(string("DescriptionTextbox.Text"), string(" "))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("DescriptionTextbox.Text"), string("You can edit various controls from your Propeller."))
    meguno.uiSetStr(string("Item.Text"), string("Including buttons,"))

    'Hide/show controls
    meguno.uiSetStr(string("MyButton.Visible"), string("false"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyButton.Visible"), string("true"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyButton.Visible"), string("false"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyButton.Visible"), string("true"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyButton.Visible"), string("false"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyButton.Visible"), string("true"))
    waitcnt(clkfreq / 2 + cnt)

    'Enable/disable controls
    meguno.uiSetStr(string("MyButton.ForeColor"), string("blue"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyButton.ForeColor"), string("red"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyButton.ForeColor"), string("green"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyButton.ForeColor"), string("black"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyButton.BackColor"), string("blue"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyButton.BackColor"), string("red"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyButton.BackColor"), string("green"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyButton.BackColor"), string("white"))
    waitcnt(clkfreq / 2 + cnt)

    'Update content of text boxes
    meguno.uiSetStr(string("Item.Text"), string("including buttons, textboxes"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyTextbox.Text"), string("you"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyTextbox.Text"), string("can"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyTextbox.Text"), string("edit"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyTextbox.Text"), string("textboxes"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyTextbox.Text"), string("from"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyTextbox.Text"), string("your"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyTextbox.Text"), string("Propeller"))
    waitcnt(clkfreq / 2 + cnt)

    'Update guage values and labels
    meguno.uiSetStr(string("Item.Text"), string("including buttons, textboxes, gauges"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyGauge.Label0"), string("you"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyGauge.Label0"), string("can"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyGauge.Label0"), string("edit"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyGauge.Label0"), string("guage"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyGauge.Label0"), string("values"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyGauge.Label0"), string("from"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyGauge.Label0"), string("your"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyGauge.Label0"), string("Propeller"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyGauge.Value"), 100)
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyGauge.Value"), 200)
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyGauge.Value"), 300)
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyGauge.Value"), 400)
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyGauge.Value"), 500)
    waitcnt(clkfreq / 2 + cnt)

    'Change checkboxes
    meguno.uiSetStr(string("Item.Text"), string("including buttons, textboxes, gauges, checkboxes"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyCheckbox.Checked"), string("true"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyCheckbox.Checked"), string("false"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyCheckbox.Checked"), string("true"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyCheckbox.Checked"), string("false"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyCheckbox.Checked"), string("true"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyCheckbox.Checked"), string("false"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyCheckbox.Checked"), string("true"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("MyCheckbox.Checked"), string("false"))
    waitcnt(clkfreq / 2 + cnt)

    'Set value for trackbars
    meguno.uiSetStr(string("Item.Text"), string("trackbars"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyTrackbar.Value"), 10)
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyTrackbar.Value"), 20)
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyTrackbar.Value"), 30)
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyTrackbar.Value"), 40)
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyTrackbar.Value"), 50)
    waitcnt(clkfreq / 2 + cnt)

    'Set value for progress bars
    meguno.uiSetStr(string("Item.Text"), string("trackbars, progress bars"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyProgressBar.Value"), 10)
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyProgressBar.Value"), 20)
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyProgressBar.Value"), 30)
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyProgressBar.Value"), 40)
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetInt(string("MyProgressBar.Value"), 50)
    waitcnt(clkfreq / 2 + cnt)

    'Control picture visibility
    meguno.uiSetStr(string("Item.Text"), string("trackbars, progress bars, pictures"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("PausePicture.Visible"), string("false"))
    meguno.uiSetStr(string("PlayPicture.Visible"), string("true"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("PausePicture.Visible"), string("true"))
    meguno.uiSetStr(string("PlayPicture.Visible"), string("false"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("PausePicture.Visible"), string("false"))
    meguno.uiSetStr(string("PlayPicture.Visible"), string("true"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("PausePicture.Visible"), string("true"))
    meguno.uiSetStr(string("PlayPicture.Visible"), string("false"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("PausePicture.Visible"), string("false"))
    meguno.uiSetStr(string("PlayPicture.Visible"), string("true"))
    waitcnt(clkfreq / 2 + cnt)
    meguno.uiSetStr(string("PausePicture.Visible"), string("true"))
    meguno.uiSetStr(string("PlayPicture.Visible"), string("false"))
    waitcnt(clkfreq / 2 + cnt)

    meguno.uiSetStr(string("DescriptionTextbox.Text"), string("You can also have tab pages, value lists, radio buttons,"))
    meguno.uiSetStr(string("Item.Text"), string("group boxes, and buttons to launch files."))
    waitcnt(clkfreq * 10 + cnt)