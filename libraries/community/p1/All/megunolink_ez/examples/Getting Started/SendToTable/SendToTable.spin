{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        TX = 30
        RX = 31
        LED = 16
        CR = $0A

VAR
  long Fish
  long Turtles
  long delay

OBJ
  meguno      : "megunolink_ez"

PUB main | timer

  meguno.start(RX, TX, 9_600)
  meguno.Str(string("Send to Property Table example"))
  meguno.Str(string("------------------------------"))

  Fish := 0
  Turtles := 0

  'Add descriptions to the table. These can be included when sending data too (see loop).
  meguno.propTableDesc(string("Fish"), string("Lives in the sea"))
  meguno.propTableDesc(string("Turtles"), string("Very slow"))

  repeat
    delay := (clkfreq + cnt)

    'Send values to MegunoLink table.
    meguno.propTableSetInt(string("Fish"), Fish)
    meguno.propTableSetInt(string("Turtles"), Turtles)

    'Update the data we're sending.
    Fish += 3
    Turtles += 1

    waitcnt(delay)