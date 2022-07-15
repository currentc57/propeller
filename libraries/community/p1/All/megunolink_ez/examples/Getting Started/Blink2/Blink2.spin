{Object_Title_and_Purpose}


CON
        _clkmode = xtal1 + pll16x                                               'Standard clock mode * crystal frequency = 80 MHz
        _xinfreq = 5_000_000

        TX = 30
        RX = 31
        LED = 16
        CR = $0A

VAR
  long  last_blink
  word  on_time
  word  off_time
  word  temp
  long  ml_cmd
  long  ml_sub

OBJ
  meguno      : "megunolink_ez"

PUB main  | now, ms, go_on, go_off, last_cnt
  last_blink := 0
  on_time := 10
  off_time := 100
  go_on := 0
  go_off := 0
  last_cnt := 0

  meguno.start(RX, TX, 9_600)
  meguno.str(string("Blink 2.0"))
  meguno.str(string("=========="))

  dira[LED] := 1
  outa[LED] := 1

  go_off := ((clkfreq / 1000) * off_time + cnt)

  repeat
    if cnt < last_cnt
      go_on -= last_cnt
      go_off -= last_cnt
    meguno.listen
    if meguno.cmdAvail > 0                             ' has megunolink sent a command?         '
      ml_cmd := meguno.getCmd                          ' get the command byte
      callCommand(ml_cmd)                               ' let's see what command we received

    if(ina[LED] == 0 and cnt >= go_on)
      outa[LED] := 1
      go_off := ((clkfreq / 1000) * on_time + cnt)
    elseif(ina[LED] == 1 and cnt >= go_off)
      outa[led] := 0
      go_on := ((clkfreq / 1000) * off_time + cnt)



PUB listAll
  meguno.str(string("onTime [ms]="))
  meguno.dec(on_time)
  meguno.tx(CR)
  meguno.str(string("offTime [ms]="))
  meguno.dec(off_time)
  meguno.tx(CR)

  meguno.uiSetNum(string("numOnTime.Value"), on_time)
  meguno.uiSetNum(string("numOffTime.Value"), off_time)

PUB setOn
  on_time := meguno.uiGetInt(string("numOnTime.Value"))

PUB setOff
  off_time := meguno.uiGetInt(string("numOffTime.Value"))

PRI callCommand(_cmd)            'parse the 1st command byte and decide how to proceed
  case _cmd
    "T" :                                               'standard Easy Nextion Library commands start with "T"
      ml_sub := meguno.readByte                       ' so we need the second byte to know what function to call
      callTrigger(ml_sub)                               ' now we call the associated function

PRI callTrigger(_triggerId)    'use the 2nd command byte from nextion and call associated function
  case _triggerId
    $00 :
      listAll                                         ' the orginal Arduino library uses numbered trigger functions
    $01 :
      setOn
    $02 :
      setOff                                          ' but since we are parsing ourselves, we can call any method we want


DAT
'name    byte  "string_data",0