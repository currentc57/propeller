{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        TX = 30
        RX = 31
        LED = 16
        CR = $0A

VAR
  long  ml_cmd
  long  ml_sub

OBJ
  meguno      : "megunolink_ez"

PUB main

  meguno.start(RX, TX, 9_600)
  meguno.str(string("MegunoLink Output Controller"))
  meguno.str(string("----------------------------"))

  dira[LED] := 1

  repeat
    meguno.listen
    if meguno.cmdAvail > 0                             ' has megunolink sent a command?         '
      ml_cmd := meguno.getCmd                          ' get the command byte
      callCommand(ml_cmd)                               ' let's see what command we received


PUB out  | state

  state := meguno.readByte

  dira[LED] := 1
  outa[LED] := state


PRI callCommand(_cmd)            'parse the 1st command byte and decide how to proceed
  case _cmd
    "T" :                                               'standard Easy Nextion Library commands start with "T"
      ml_sub := meguno.readByte                       ' so we need the second byte to know what function to call
      callTrigger(ml_sub)                               ' now we call the associated function

PRI callTrigger(_triggerId)    'use the 2nd command byte from nextion and call associated function
  case _triggerId
    $00 :
      out                                         ' the orginal Arduino library uses numbered trigger functions
                                                  ' but since we are parsing ourselves, we can call any method we want



DAT
name    byte  "string_data",0
